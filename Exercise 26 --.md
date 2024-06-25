# Exercise 26 -- 

Only a small fraction of the data is unreadable, missing, or corrupt -- Create and clean up a two-column data frame. each column needs to be cleaned differently for us to answer the question -- like:

```python
df = pd.read_csv('celebrity_deaths_2016.csv',
                 usecols=['dateofdeath', 'age'])
f['month']=df.dateofdeath.str[5:7]
# then turn it into the index like:
df=df.set_index('month')
df=df.sort_index()
# trigger an error
df['age']=df['age'].astype(np.int64)
```

This will fail fro two reasons -- first, some values contain characters other than digits -- Second, some values are `NaN`-- which as floating-point value, cannot be coerced into integers, should probably check to see how many they are -- can do that with the `isnull().sum()`trick -- like:

`df['age'].isnull().sum()/len(df.age)`

Can sacrifice that many rows and not worrty about how much data we are losing -- can remove the `NaN`values
d`f =df.dropna(subset=['age'])`

Again, we are using the `subset`parameter, note that there are any rows in the index with `NaN`values, and how can we remove the rest of the troublesome data -- that is how can we remove rows that contain non-digit characters -- will rely on the `str.isdigit`method -- return `True`if a string contains only digits (also not empty) -- Also, it returns `False`if there is a `-`sign or decimal point. like: `df['age'].str.isdigit()`

Can then use this boolean series as a mask index to remove rows in `df`whose ages cannot convert into integers:
`df = df[df['age'].str.isdigit()]`

As is often the case, pandas has a more elegant -- `pd.to_numeric()`function -- this function -- which is defined at the top of `pd`level rather than on a series or dataframe -- tries to create a new series with numeric values like:

```python
df['age']=pd.to_numeric(df['age'])
```

It turns out `pd.numeric()`has some *additional* functionality -- allowing us to skip the step of ousing `str.isdigit()`-- by default, the `pd.to_numeric`will raise an exception if it encounters a string that cannot be turned into an int or float. But if we pass the keyword argument `errors='coerce'`, it will turn any values it can’t convert into `NaN`-- then can ignore all use like:

`df['age']=pd.to_numeric(df['age'], errors='coerce`')`

`df= df.loc['df[age]'<120]`

#### Beyond the exercises

- Add a new column, day from the day of the month in which the celebrity died like:

```python
df.loc['02':'07', 'age'].mean()
df = df.set_index(['month', 'day'])

# Sort the index
df = df.sort_index()
# average from Feb.15 through July 15
df.loc[('02', '15'):('07', '15'), 'age'].mean()
```

- The csv file contains another column -- Now replace the `NaN`with the string `unknown`

```python
df = pd.read_csv('celebrity_deaths_2016.csv',
                usecols=['dateofdeath', 'age', 'causeofdeath'])
df['cuaseofdeath']=df['causeofdeath'].fillna('unknown')
```

- If someone asked whehter cancer is in the top causes -- just `head(10)`used.

### Titanic interploation -- 

When data contains `NaN`values, have a few options -- 

- Remove them
- Leave them
- Replace them with sth else

If choose the option 3 -- *replace them with sth else* -- that raises another question -- what do you want to replace the NaN value with -- A value you have chosen -- sth calcuated from the data frame itself sth calculated on a per-column basis

## Concurrency Foundations

- Understanding concurrency and parallelism
- Why concurrent isn’t always faster
- The impacts of CPU-bound and I/O -bound workloads
- Using channels vs mutexes
- Understanding the differences between data races and race conditions
- Working with go contexts

### DON’T Mix up concurrency and parallelism

May not clearly understand the differences between concurrency and parallism. For in the new process, every part of the system is independent, the coffee shop should serve consumers twice as fast -- this is just a *parallel* implementation of a coffee shop. Then if want to scale, keep duplicating waiters and coffee machines over and over. Another approach might be to split the work done by the waiters and have one in charge of accepting orders and another one who grind... With the new design, don’t make things paralle, but the overall structure is affected. For this, unlike parallelism, which is about doing the same thing multipel times at once -- *concurrency* is just about structure.

Fore, assuming one thread represents the waiter accepting orders and another represents the coffee machine -- Each thread is independent but has to coordinate with others. *Each thread is independent* but has to coordinate with others.

With some design, can notice sth important - *concurrency* enables *parallism* -- concurrency provides a structure to solve a problem with parts that may parallelized. -- Concurrency is about dealing with lots of things at once, Parallelism is about doing lots things at once.

### Don’t think concurrency is always faster

The overall performance of solution depends on many factors, such as the efficiency of your structure, which prts can be tackeld in paralle, and the level of contention among the computation units.

#### Go scheduling

A thread is the smallest unit of processing that an OS perform. These threads can be:

- `Concurrent` -- Two or more can start, run and complete in overlapping time periods
- `Parallel`-- The same task can be executed multiple times at once.

And the OS is just repsonsible for scheduling the thread’s processes optimally so that -- 

- All the threads can consume CPU cycles without being starved for too much time.
- The workload is distributed as evenly as possbile among different cpu cores.

### When to use channels or mutexes

Given a concurrency problem, may not alwyas be clear whether we can omplement a solution using channels or mutexes -- Cuz Go promotes sharing memory by communication -- one mistake could be always force use of the channels -- Should see the two options as complementary.

Channels are a communication mechanism -- internally -- a channel is a pipe we use to send and receive values and that allows us to *connect* concurrent goroutines. Unbuffered, and Buffered. FORE:

- G1 and G2 are parallel goroutines -- may be two goroutines executing the same function that keeps receiving messages from a channel -- or two goroutines executing the same HTTP handler at the same time
- On the other hand, G1 and G3 are concurrent goroutines, as are G2 and G3 -- all are part of overall concurrent structure, G1 and G2 first, G3 next step.

In general, parallel goroutines have to *synchronize* -- When they need to access or mutate a shared resource fore, slice -- Sync is enforced with mutexes but not with any channel types. So:

*In general, sync between parallel goroutines should be achieved via **mutexes***.

Conversely -- in general, concurrent goroutines have to *coordinate* and *orchestrate*. Here, fore, if G3 needs to aggregate results from both G1 and G2, G1 and G2 need to signal to G3, that a new intermediate result is available. And this coordination falls under the scope of communication -- channels.

Regarding concurrent goroutines -- there is case where want to transfer the ownership of a resource from one step to another -- fore -- if G1, 2 are enriching a shared resource at some point -- consider this job as complete.

Mutexes and channels have different semantics - whenever want to share a state or access a shared resource, mutexes ensure exclusive access to this resource.

### Understanding race problems

Can be among the hardest and most insidious bugs -- Must understand cruical aspects such as data races and race conditions -- their possible impacts, and how to avoid.

#### Data race vs. race conditions

A data race occurs when two or more goroutines simultaneously access the same memory location and at least one of these is writing. fore:

```go
i := 0
go func(){i++}() go func(){i++}()
```

When using the `-race`option, warn us that a data race occurred. -- `i++`statement can be decomposed into 3 operations -- like read, increment and write back.

Just note that there is no guarantee that the first goroutine will either start or complete before the second one in the previous example. Can also face the case of an interleaved execution where both run concurrently. So, this is a possible impact of a data race -- If two simultaneously access the same memory location with at least one writing to that, the result can be hazardous.

Note that the atomic operations can be done in Go using the `sync/atomic`package like:

```go
func main() {
	var i int64
	go func() {
		atomic.AddInt64(&i, 1)
	}()
	go func() {
		atomic.AddInt64(&i, 1)
	}()
	time.Sleep(time.Second)
	fmt.Println(i)
}
```

Both goroutines update `i`atomically -- an Atomic operations can’t be interrupted -- thus preventing two acesses at the same time. Another option is to sync the two goroutines with an ad hoc data structure like a `mutex`. *Mutex* in go for mutual *exclusion* -- a mutex ensures that at most one goroutine accesses a so-called CS.

```go
i := 0
mutex := sync.Mutex{}
go func(){
    mutex.Lock()
    i++
    mutex.Unlock()
}() //...
```

As mentioned, the `sync/atomic`package works only with specific types, if want something else, can’t rely on `sync/atomic`. Another is to preventing is using channels -- like;

```go
i := 0
ch := make(chan int)
go func() {
    ch <- 1
}()
go func(){
    ch <- 1
}()
i+= <-ch
i+= <-ch
```

For this, each goroutine sends a notification via the channel that should increment i by 1 -- The parent collects the notification and increments i.

Instead of having two goroutines increment a shared variable -- now each one makes an assignemnt -- will follow the approach of using a mutex to prevent data races -- fore:

```go
go func(){
    mutex.Lock()
    defer mutex.Unlock()
    i=1
}()
go func(){
    mutex.Lock()
    defer mutex.Unlock()
    i=2
}()
```

For this, there is not a data race -- both access the same varaible -- but, not at the same time -- But this example is now NOT deterministric. -- note data race, but has a *race condition* -- a race condition occurs when behavior **depends on the sequence or the timing** of events that can’t be controlled.

So, ensuring a specific execution sequence among gorotuines is a question of coordination and orchestraction. Channels can be a way to solve this. So, a data race occurs when mutliple simultaneously access the same memory location and at least one of these is writing -- a data race means unexpected bahavior -- however, a data-race-free app doesn’t necessarily manes upexpected behavor.

And an app can be free of data race but still have behavior that depends on uncontrolled events -- fore, race condition.

## Data Validation

- Check the fields are not empty
- Check that the `title`is not more than 100 character long.
- Chec that the `expires`matches the permitted values.

```go
func (app *application) createSnippet(w http.ResponseWriter, r *http.Request) {
    err := r.ParseForm()
    if err != nil {
        app.ClientError(w, http.StatusBadRequest)
        return
    }
    title := r.PostForm.Get("title")
    content := r.PostForm.Get("content")
    expires := r.PostForm.Get("expires")
    
    // initialize a map to hold any validation errors
    errors := make(map[string]string)
    if strings.TimeSpace(title) == "" {
        errors["title"]="This field cannot be blank"
    }else if utf8.RuneCountInString(title) > 100 {
        errors["title"]="this filed is too long"
    }
    
    // check the content field is not blank
    if string.TrimSpace(content)=="" {
        errors["content"]="This filed cannot be blank"
    }
    
    // check the expires fore:
    if strings.TrimSpace(expires)=="" {
        errors["expires"]= "This field cannot be blank"
    }else if expires != "365" && expires !="7" && expires !="1" {
        errors["expires"]= "this field is not valid"
    }
    
    // then any errors dump them
    if len(errors)>0 {
        fmt.Fprint(w, errors)
        return
    }
}
```

#### Displaying validation errors and Repopulating fields

If there are any validation errors we want to re-display the form, highlighting the fields which failed validation and automatically re-populating any prevously submitted data. `FormErrors`to hold any validation errors, and `FormData`to hold *any previously submitted* data like:

```go
type templateData struct {
    CurrentYear int
    FormData url.Values // note that
    FormErrors map[string]string
    //...
}

// cmd/web/handlers.go
func (app *application) createSnippet(w http.ResponseWriter, r *http.Request) {
    err := r.ParseForm()
    if err != nil {
        app.clientError(w, http.StatusBadRequest)
        return
    }
    
    title:= ...
    //...
    errors := make(map[string]string)
    if strings.TrimSpace(title)=="" {
        errors["title"]=...
    }
    //.. some other conditional branch
    // If there are any valiadtion error, re-display the `create.page.html`
    // template passing in the validation errors and prevously submitted 
    if len(errors)>0 {
        app.render(w, r, "create.page.html", &templateData {
            FormErrors: errors,
        	FormData: r.PostForm,
        })
        return
    }
    id, err := app.snippets.Insert(...)
}
```

So now when there are any validation errors we are re-displaying the create.page.html template, passing in the map of the errors in the `FormErrors`field of the template data, and passing in the prevously submitted data in the `FormData`filed. -- 

The underlying type of the `FormErrors`-- is `map[string]string`and for maps, it’s possible to access the value for a given key by simply postfixing dot with the key name. And for maps, it’s possible to access the value for a given key by simply postfixing dot with the key name. like `{{.FormErrors.title}}`in the template.

And note that the underlying type of the `FormData`is `url.Values`and we can use its `Get()`method to retreive the value for a field. -- just like did in the `createSnippet()`. Fore : `{{.FormData.Get "title"}}`

```html
{{define "main"}}
    <form action="/snippet/create" method="post">
        <div>
            <label>Title:</label>
            {{with .FormErrors.title}}
                <label class="error">{{.}}</label>
            {{end}}
            <input type="text" name="title" value="{{.FormData.Get "title"}}">
        </div>

        <div>
            <label>Content:</label>
            {{with .FormErrors.content}}
                <label class="error">{{.}}</label>
            {{end}}
            <textarea name="content">{{.FormData.Get "content"}}</textarea>
        </div>
        <div>
            <label>Delete in:</label>
            {{with .FormErrors.expires}}
                <label class="error">{{.}}</label>
            {{end}}
            {{$exp := or (.FormData.Get "expires") "365"}}
            <input type="radio" name="expires"
                   value="365" {{if (eq $exp "356")}}checked {{end}}> One year
            <input type="radio" name="expires"
                   value="7" {{if (eq $exp "7")}}checked{{end}}> One week
            <input type="radio" name="expires"
                   value="1" {{if (eq $exp "1")}}checked{{end}}> One Day
        </div>
        <div>
            <input type="submit" value="Publish snippet">
        </div>
    </form>
{{end}}
```

Take a moment to talk about -- `{{$exp := or(.FormData.Get "expires") "365"}}`This is essentially creating a new `$exp`template variable which use the `or`template function to set the variable to the value yieled by `.FormData.Get "expires"` or if that is empty then the deafult vlaue of 365 instead.

Notice here, we’ve used `()`parentheses to group the `.FormData.Get()`and its parameters in order to pass its output to the `or`action. like: `{{if (eq $exp "356")}}checked{{end}}`

### Scaling Data Validation

Now in the position where our app is validating the form data according to our business rules and gracefully handling any validation errors -- And while the app fine as a one-off- if app has many forms then can end up with quite a lot of repetition of your code and validation rules.

So, address this by creating a `forms`package to abstract some of this behavior and reduce the boilerplate code in the handler -- won’t actually change how the app works for the user at all just refactoring of our codebase.

```go
// Define a new errors type, which we will use to hold the validation error
// message for forms.
type errors map[string][]string

// Add Implement an Add() method to add error messages for a given field to the map
func (e errors) Add(field, message string) {
	e[field] = append(e[field], message)
}

// Get to retrieve the first error message for a given field from the map
func (e errors) Get(field string) string {
	es := e[field]
	if len(es) == 0 {
		return ""
	}
	return es[0]
}
```

And then in the `form.go`file like:

```go
package forms

import (
	//...
)

// Form create a custom Form struct, anonymously embeds a url.Values object
type Form struct {
	url.Values
	Errors errors
}

// New Defines a new func to initialize a custom Form struct,
func New(data url.Values) *Form { // takes the form data
	return &Form{
		data,
		errors(map[string][]string{}),
	}
}

// Required implements a required method to check that specific fields
// in the form data.
func (f *Form) Required(fields ...string) {
	for _, field := range fields {
		value := f.Get(field)
		if strings.TrimSpace(value) == "" {
			f.Errors.Add(field, "This field cannot be blank")
		}
	}
}

// MaxLength implements to check the langth
func (f *Form) MaxLength(field string, d int) {
	value := f.Get(field)
	if value == "" {
		return
	}

	if utf8.RuneCountInString(value) > d {
		f.Errors.Add(field, fmt.Sprintf("This field is too long (max is %d", d))
	}
}

// PermittedValues to check a specific field
func (f *Form) PermittedValues(field string, opts ...string) {
	value := f.Get(field)
	if value == "" {
		return
	}
	for _, opt := range opts {
		if value == opt {
			return
		}
	}
	f.Errors.Add(field, "This field is invalid")
}

// Valid return true if there are no errors
func (f *Form) Valid() bool {
	return len(f.Errors) == 0
}
```

