# Pusing to a Remote Repository

To push a local branch to your remote repository, you will use the `git push`command and pass in the shortname for the remote repository and the name of the branch that you want to push. For the `rainbow`repository, the shortname U will use is `origin`and the branch you will push is `main`.

Noticed that when push a specific branch to a remote repository, only the data from that branch is uploaded to the remote repository. but the `feature`branch was not pushed to the remote repository.

At the moment, in the `rainbow`repository, the `main`and `feature`branches have the same commits. In other words, their development histories, which cna be traced by following the commits and the parents links backward, consist of the same commits.

```sh
git switch feature
git push origin feature
git branch --all
git log
```

In the step 3, can see that in the `rainbow`repository there are two remote tracking branches

In step 4, can see that in the `rainbow-remote`repository there are two remote branches.

You have now created a remote repository with data -- mentioned that there are two ways to make changes to a remote repository -- 

1. By logging in to the hosting service via its website and making changes there directly.
2. By making changes in your local repository and uploading those changes to the remote repository on the hosting service.

In this chapter we covered an example of the second situation -- 

#### Working on a remote Repository Directly on a Hosting service

However, it is also possible to use the UI of a hosting service’s website to carry out a lot of actions that are similar to tehse -- fore, on a hosting service you can make commits directly on a remote repository, can crete remote branches, can also merge branches through a feature called *pull request*.

### Cloning and Fetching

Going to start simulating what it would be like to work with a friend on the `Rainbow`project -- to do that , you are going to learn about cloning remote repositoies and how this differs from initializing repostories locally. Will also learn more about defining upstream branches, deleting branches, and fetching data from a remote repository.

Some text editors that have Git integrations allow U to define certain settings to Git -- Fore, VSC has a feature called *Autofetch* that will periodically fetch changes from a remote repository -- this feature is displayed by default, and or U to be able to do the exercises in this -- should remain disabled.

#### State of Local and Remote Repositories

At the start of this chapter, you should have a local repository called `rainbow`and a remote repository called `rainbow-remote`-- These two repositories should be *in sync -- should contain the same commits and branches*.

#### Cloning a Remote Repository

Learned that Git is a useful tool for collaboration -- Cloning remote repositories is an essential part of being able to collaborate with other people on a Git project, since it allows them to work with their own copy of the repository on their computer.

Fore coauthor will need to clone the remote repository to have their own copy of the Book project on their computers so they can start working with me on the book. To enable this, they will need to have an account with whichever hosting service is hosting the remote repository. Then will have to grant them editing access to the repository so they can comment and contribute, regardless of whether it is public or private.

Shows why cloning repositories is such an important part of collaborating with others on any Git project. Look at how you are going to simulate the experience of working with someone else.

#### To collaboration Simulation

Normally, if two people are working on the same proj, each will have a local repository on their own computer and each will contribute to one remote repository.

Then *pretend* that this second local repository is on your friend’s computer -- from now on, when refer to -- Will perform the action youself in the `friend-rainbow`repostiory.

After your friend clones the remote repository, will be working with two local repositories.

In Git, use the term *clone* or *cloning* to refer the process of copying a remote repository onto a computer to create a local repository and the command use to do this is `git clone`-- To clone a remote repostiory, use the `git clone`and pass in the remote repository URL. Optionally, a project directory name.

```sh
git clone <URL> <directory_name>
```

If don’t pass a directory name, then the local repository will be assigned the remote repostiory project name. Fore, if don’t pass a project directory name in the upcoming Follow Along when clone -- 

1. Create a project directory inside the current directory
2. Create (initialize) the local repository
3. Download all the data from the remote repository
4. Add a connection to the remote repository that was cloned.

## NO determinisitc behavior using `select`and channels

One common mistake made by Go developers while working with channels is to make wrong assumptions about how `select`behaves wtih multiple channels. A `false`asssumption can lead subtle bugs may be hard to identify and reproduce.

- `messageCh`for new messages to be processed
- `disconnectCh`to receive notifications conveying disconnections.

For this, say want to pioritize `messageCh`-- fore, if a disconnection occurs, want to ensure that we have received all the messages before returning -- 

```go
for {
    select {
    case v:= <-messageCh:
        fmt.Println(v)
    case <-discnnectCh:
        fmt.Println("disconnection, return")
        return
    }
}
```

1. Use the `select`statement to receive from multiple channels
2. Receives new messages
3. Receives disconnections.

We use `select`to receive from multiple channels. But -- note -- we want to prioritize `messageCh`-- might assume that we should write the `messageCh`case first and the `disconnectCh`case next -- but does this code -- fore:

```go
for i:=0; i<10; i++ {
    messageCh <-i // if buffered by 5
}
disconnectCh <- struct{}{}
```

Instead of consuming the 10 messages -- If one or more of the communications can proceed, a single one that cna proceed is chosen via uniform *pseudo-random* selection.

Note that, unlike `switch`statement, where the first case with a match wins, the `select`statement selects randomly if multiple options are possible.

This behavior might look odd -- good reason for starvation. Suppose the first possible communication chosen is based on the source order -- In that case, may fall into a situation where fore, we only receive from one channel because of a faster sender. So, even though `case v:= <-messageCh`is the first in ource order -- there is no guarantee about which case will be chosen.

And there are different possibilities if we want to receive all the messages before returning in case of disconnction -- 

- Make `messageCh`an unbuffered note that -- cuz the sender goroutine blocks until the receiver goroutine is ready, 

  ```go
  func main() {
  	messageCh := make(chan int)
  	disconnectCh := make(chan struct{})
  
  	go func() {
  		for {
  			select {
  			case v := <-messageCh:
  				fmt.Println(v)
  			case <-disconnectCh:
  				fmt.Println("disconnection return")
  			}
  		}
  	}()
  
  	for i := 0; i < 10; i++ {
  		messageCh <- i
  	}
  	disconnectCh <- struct{}{}
  }
  ```

- Use a single channel instead of two channels -- fore. Can define a `struct`that conveys either a new message or disconnection. Channels guarantee that the order for the messages sent is the same as for the messages received.

If we fall into the case where we have multiple producer goroutines, it may be impossible to guarantee which one writes first. Hence, whether we have an unbuffered or a single channel, it will lead to race condition among the producer goroutines. In this case, can implement the following solution -- 

1. Receive from either `messageCh`or `disconnectCh`.
2. If a disconnection is received
   1. Read all the existing messages in `messageCh`if any
   2. Then return

```go
go func() {
    for {
        select {
            case v := <-messageCh:
            fmt.Println(v)
            case <-disconnectCh:
            for {
                select {
                    case v := <-messageCh:
                    fmt.Println(v)
                    default:
                    fmt.Println("disconnection, return")
                    return
                }
            }
        }
    }
}()
```

This solution uses an inner `for/select`with two cases -- one on `messageCh`and a `default`case. Using `default`in a `select`statement is chosen *only if none of the other cases match*. 

We receive the disconnection and enter in the inner `select`-- here as long as messages remain in the `messageCh`, `select`will always prioritize the first case over `default`. Once we have received all the messages from `messageCh`, `select`does not block and chooses `default`case -- return and stop the goroutine.

This is a way to ensure that we receive all the remining messages from a channel with a receiver on multiple channels. When using `select`with multiple channels, must remember that if mutliple options are possible, the first cse in the source order does not automatically win.

### Using notification channels

Channels are mechanism for communicating acorss goroutines via signaling -- a Signal can be either with or without data. But for Go programmers, it’s not always straightforward how to tackle the latter case.

Look at a concrete example -- create a channel that will notify us whenever a certain disconnection occurs -- 

`disconnectCh := make(chan bool)`

Let’s say we interact with an API that provides us with such a channel. Cuz it’s a channel of `Booleans`-- can receive either `true`or `false`messages -- and it’s probabley clear what `true`conveys -- but what does the `false`means...

And, should we even expect receive `false`-- If that is the case -- don’t need a specific value to convey some info, just need a channel *without data* -- the idiomatic way to handle it is a channel of empty structs: `chan struct{}`.

```go
var s struct{}
fmt.Println(unsafe.Sizeof(s)) // 0
```

So an empty struct is a *de facto* standard to convey an absence of meaning -- fore, if need a hash set structure, we should use an emtpy struct as a value `map[K]struct{}`. Applied to channels, if we want to create a channel to send notifications without data, the appropriate way to do so in go is a `chan struct{}`-- one of the best-known utilizations of a channel of empty structs comes with Go contexts, which we discuss in this -- 

A channel can be with or without data. If want to design an idiomatic API in regard to Go standards, remember that a channel without data should be expressed with a `chan struct{}`type. it clarifies for receviers that they shouldn’t expect any meaning from a message’s content -- only the fact that they have received a message -- such channels in Go are just called *notification channels*.

```go
func (app *application) showSnippet(w http.ResponseWriter, r *http.Request) {
	// When httprouter is parsing a request, the values of any named parameters
	// will be stored in the request context. talk about request context
	// in detail later in the book.
	params := httprouter.ParamsFromContext(r.Context())

	// can then use the `ByName()` method to get the value of the id
	id, err := strconv.Atoi(params.ByName("id"))
	if err != nil || id < 1 {
		app.notFound(w)
		return
	}

	snippet, err := app.snippets.Get(id)
	if err != nil {
		if errors.Is(err, models.ErrNoRecord) {
			app.notFound(w)
		} else {
			app.serverError(w, err)
		}
		return
	}

	app.render(w, r, "show.page.html", &templateData{Snippet: snippet})
}
```

### Custom error Handlers

Before continue, might also like to try making the following two requests -- not existent /view/99 fore -- Can see both of in 404 -- but they have slightly diferent response bodies. Cuz this is happening cuz the first request ends up calling out to our `app.notFound()`helper when no snippet with ID 99 can be found, whereas the second response is returned automatically by `httprouter`when no matching route is found.

Fortunately, `httprouter`makes it easy to set a custom handler for dealing with 404 resposnes -- like:

```go
func (app *application) routes() http.Handler {
	router := httprouter.New()
	
	// Create a handler function which wraps our notFound() helper, and then assign it 
	// as the custom handler for 404 not found, can also set a custom handler for 405
	// method not allowed
	router.NotFound= http.HandlerFunc(func(w http.ResponseWriter, r *http.Request){
		app.notFound(w)
	})
    //...
}
```

#### Conflicting route patterns 

It’s important to be aware that `httprouter`doesn’t allow *conflicting route patterns* which potentially match the same request. So, fore, cannot register a route like `GET /foo/new`and another route with a named parameter segment or catch-all parameter that conflicts with it. And in most cases this is a positive thing. Cuz conflicting routes aren’t allowed, there are no routing-priority rules that you need to worry about, and it reduces the risk of bugs and unintended behavior in your application.

But, if want to need to support conflicting routes - then would recommend using `chi`or `gorilla/mux`instead.

#### Customizing httprouter behavior

The `httprouter`package provides a few configuration options that you can use to customize the behavior of your application futher, including enabling *tranling slash redirections* and enabling *automatic URL path cleaning*.

### RESTful routing

There are a couple of reasons -- fore: `GET /snippts/:id`and `GET /snippets/new`routes *conflict* with each other a HTTP request to `/snippets/new`potentially matches both routes -- as mentioned -- `httprouter`doesn’t allow conflicting route patterns -- it’s generally good practice to avoid them anyway cuz they are a potential source of bugs. The second reason is that the HTML form presented on `/snippets/new`would need to post to `/snippets`when submitted, this means that when we re-render the HTML form to show any validation errors, the URL in the user’s browser will also change to `/snippets`.