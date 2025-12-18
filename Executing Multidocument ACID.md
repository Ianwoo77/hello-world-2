# Executing Multidocument ACID

Explains the fundamental concept of dbs transactions and how they have evloved within mdb -- 

- Def of Transactions -- Are groupd of related read and write operations that act as a single unit. They follow the *all or nothing* rule -- either every operation succeeds,or the entire set is rolled back to prevent partial data updates.
- Evolution of mdb -- Historically -- mdb relied on single-document atomicity to ensure data consistency.

By introduction of multidocument atomicity, consistency, isolation, and ACID transactions, Mdb has significantly broadened its applicability and enhanced its capabilitiy to ahndle complex transaction scenarios.

## Programming with types

Might have encountered interface type like `io.Writer`, fore, here is a function that declares a parameter `w`of type `io.Writer`-- 

```go
func PrintTo(w io.Writer, msg string) {
    fmt.Fprintln(w, msg)
}
```

- The power of interface -- An interface defines a set of behaviors rather than a specific data structure. A func that takes an interface parameter is flexible, it can accept an type -- even those not yet invented.
- Constraining parameters - Interfaces allow developers to specify exactly what they need from a parameter. Fore, a `Stringer`interface ensures that whatever value is passed in has a `String()`method, allowing the function to call that method without needing to know the underlying type.

#### Type assertions and switches

```go
switch v:= x.(type) {
case int:
    return v+y
case float64:
    ...
}
```

Fore, have to write sth like this -- 

```go
func Identity(v any) any {
    return v
}
```

This works, but isn’t really satisfactory -- with `AddAnything()`in the previous chapter don’t have any way to tell Go that the function’s parameter and its result must be the *same* concrete type -- 

```go
func Identity[T any](v T) T {
    return v
}
```

Notice that although it looks similar to the non-generic version, there is an important difference, whatever T turns out to be, both the parameter and the function’s result must be of that type.

```go
func TestPrintAnythingTo_PrintsToGivenWriter(t *testing.T) {
	t.Parallel()
	buf := new(bytes.Buffer)
	PrintAnytingTo(buf, "Hello, world")
	want := "Hello, world\n"
	got := buf.String()
	if want != got {
		t.Errorf("want %q; got %q", want, got)
	}
}
func PrintAnytingTo[T any](w io.Writer, p T) {
	fmt.Fprintln(w, p)
}
```

#### Running the test

Run the test using your editor, or the `go test`command -- you will wee that right now the doesn’t compile, cuz the required function doesn’t exist -- 

##### Composite types

So far, figured out how to define a generic function -- for some type `T`, takes a parameter of type `T`-- 

Restricted to declaring only parameter of type `T`itself, or could we also take some composite type -- Slices of some arbitrary type -- could indeed, suppose wanted to write a function `Len`that returns the length of a given slice.

```go
func Len[E any](s []E) int {}
```

It’s conventional, though not required, to capitalizse the names of type parameters. Those names can be whatever you like -- but again it’s conventional to use a single letter.

##### Other gneric composite types

Can also use a type parameter in other kinds of composite type. Can write a generic func on a *channel* of some element type `E`-- `func Drain[E any](ch <-chan E) {}`

Could even write a variadic function -- that is a function that takes a variable number of arguments -- 

`func Merge[E any](chs ...<-chan E) <-chan E {}`

Actually implementing these functions is a topic for another book -- sure can see the possibilities.

#### Generic types

Generic functions are great, but can do more, can also write generic types, -- `type SliceOfInt []int`. Just as an `int`variable can only hold `int`values -- a `[]int`slice can only hold `int`elements.

##### Defining a generic slice type -- 

Could we write a *generic* type definition that takes a type parameter, just like a generic func -- could:

`type Bunch[E any] []E`-- A generic type is always instantiated on some specific type when it’s used in a program. That is to say -- `Bunch[int]`will be a slice of `int`, a `Bunch[string]`will be a slice of strings. Can define:

```go
b := Bunch[int]{1,2,3}
```

##### The elements all have the same type

It’s very important to understand that - even though a `Bunch`is defined as a slice of `E`for any type `E`, any particular Bunch can’t contain values of *different* types.

```go
b := Bunch[int]{1,2,3}
b = append(b, "hello")
```

Can have `Bunch[int]`or `Bunch[string]`or a Bunch of elements of any other specific type.

Generic types need to be instantiated -- in a sense, no generic types in Go - Can define generic type like `Bunch[E]`, but to actually use them in your program - you need to instantiate them on some specific type

```go
type Group[E any] []E

func TestGroupContainsWhatIsAppendedToIt(t *testing.T) {
	t.Parallel()
	got := group.Group[string]{}
	got = append(got, "hello")
	got = append(got, "world")
	want := group.Group[string]{"hello", "world"}
	if !slices.Equal(want, got) {
		t.Errorf("want %v, got %v", want, got)
	}
}
```

### Context

```go
type SpyStore struct {
	response  string
	cancelled bool
	t         *testing.T
}

func (s *SpyStore) Fetch() string {
	time.Sleep(100 * time.Millisecond)
	return s.response
}

func (s *SpyStore) Cancel() {
	s.cancelled = true
}

func (s *SpyStore) assertWasCancelled() {
	s.t.Helper()
	if !s.cancelled {
		s.t.Errorf("store was not told to cancel")
	}
}

func (s *SpyStore) assertWasNotCancelled() {
	s.t.Helper()
	if s.cancelled {
		s.t.Errorf("store was told to cancel")
	}
}
```

Our handler will need a way of telling the `Store`to cancel the work so update the interface -- 

```go
type Store interface {
	Fetch() string
	Cancel()
}
```

Need to adjust our spy so it takes some time to return `data`and a way of knowing it has been told to cancel.

```go
func TestServer(t *testing.T) {
	data := "hello, world"

	t.Run("returns data from store", func(t *testing.T) {
		store := &SpyStore{response: data, t: t}
		srv := Server(store)
		req := httptest.NewRequest(http.MethodGet, "/", nil)
		res := httptest.NewRecorder()
		srv.ServeHTTP(res, req)

		if res.Body.String() != data {
			t.Errorf("got %q, want %q", res.Body.String(), data)
		}
		store.assertWasNotCancelled()
	})

	t.Run("tells store to cancel work if request is cancelled", func(t *testing.T) {
		store := &SpyStore{response: data, t: t}
		srv := Server(store)
		req := httptest.NewRequest(http.MethodGet, "/", nil)
		cancellingCtx, cancel := context.WithCancel(req.Context())
		time.AfterFunc(5*time.Millisecond, cancel)
		req = req.WithContext(cancellingCtx)
		res := httptest.NewRecorder()
		srv.ServeHTTP(res, req)
		store.assertWasCancelled()
	})
}
```

##### Write enough code to make it pass - 

Remember to be disciplined with TDD. Write the minimal amount of code to make our test pass -- 

```go
func Server(store Store) http.HandlerFunc {
    return func(w http.ResponseWriter, r *htt;.Request) {
        store.Cancel()
        fmt.Fprint(w, store.Fetch())
    }
}
```

##### Key takeaways --

- The problem with manual Cancellation -- manually managing a `Cancel()`method for a service like `Store`is inefficient and error-prone -- of `Store`has its own dependencies -- U would have to manually ensure the cancellation signal propagates down the entire chain.
- Context as a std solution -- The `context`package provides a consistent, unified way to handle cancellation, unified way to handle cancellation, when a parent context is canceled, all derived contexts are automatically cancelled, ensuring a clean shutdown across all layers.

Instead of building custom cancellation logic, Go developers should propagate context throughouth the entire call stack. This allows each component in the chain to be responsible for stopping itself when the context is cancelled.

#### Write the test first

Have to change our existing tests as their responsibilities are changing -- the only thing our handler is resonsible for now is making sure it sends a context through to the downstream `Store`and that is handles the error that will come from the `Store`when it is cancelled.

```go
type SpyStore struct {
	response string
}

func (s *SpyStore) Fetch(ctx context.Context) (string, error) {
	data := make(chan string, 1) // whey have 1 buffer?
	go func() {
		var result string
		for _, c := range s.response {
			select {
			case <-ctx.Done():
				fmt.Println("spy store got cancelled")
				return
			default:
				time.Sleep(10 * time.Millisecond)
				result += string(c)
			}
		}
		data <- result
	}()

	select {
	case <-ctx.Done():
		return "", ctx.Err()
	case res := <-data:
		return res, nil
	}
}

type SpyResponseWriter struct {
	written bool
}

func (s *SpyResponseWriter) Header() http.Header {
	s.written = true
	return nil
}

func (s *SpyResponseWriter) Write([]byte) (int, error) {
	s.written = true
	return 0, errors.New("not implemented")
}

func (s *SpyResponseWriter) WriteHeader(statusCode int) {
	s.written = true
}
```

In Go concurrency, using a buffered channel with a size of 1 in this specific pattern is a common best practice to prevent **goroutine leaks**.

Here is the breakdown of why that `1` is there and what happens if you remove it.

##### 1. Preventing Goroutine Leaks

The primary reason for the buffer is the `select` block at the end of your function.

If the `ctx.Done()` case wins (meaning the request was cancelled or timed out), the `Fetch` function returns immediately. If `data` were an **unbuffered** channel, the internal goroutine would be stuck forever trying to send the `result` into a channel that no one is listening to anymore.

##### 2. The Execution Flow

- **With `make(chan string, 1)`:** Even if the main `Fetch` function has already returned due to a timeout, the background goroutine can still drop its result into the "mailbox" (the buffer) and exit cleanly. The garbage collector can then reclaim the channel and the goroutine.
- **With `make(chan string)` (Unbuffered):** The background goroutine will hang at the line `data <- result` until the program terminates, because the receiver is gone. This consumes memory and resources unnecessarily.

Have to make our spy act like a real method that works with `context`.