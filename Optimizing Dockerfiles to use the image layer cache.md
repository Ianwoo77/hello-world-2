# Optimizing Dockerfiles to use the image layer cache

There is a layer of your `web-ping`image that contains the app’s Js file. And if you *make a change* to that file and rebuild your image, get a new image layer -- Docker assumes that the layers in docker image follow a defined sequence, so if you change a layer in the middle of that sequence, Docker doesn’t assume it can reuse the latter layer in the sequence. make some change, then type:
`docker image built -t web-ping:v2`

Will see the same output as upper -- steps 2 through 5 of the build use layers from the cache. If the instruction doesn’t change between builds, and the content going into the instruction is the same, d*ocker knows it can use the previous layer in the cache*. That saves executing the Dockerfile instruction again and generating a duplicate layer.

Docker calculates whether the input has a match in the cache by generating a hash, which like a digital fingerprint representing the input. The hash is made from the Dockerfile instruction and the contents of any files being copied. If there is no match for the hash in the existing image layers, Docker executes the instruction, and that breaks the cache.

Any Dockerfile you write should be optimized so that the instructions are ordered by now frequently they change. With instructions that are unlikely to change at the start of the Dockerfile. The goal for most builds to only need to execute the last instruction, using the cache for everything else. There are only 7 instructions in the `web-ping`, The `CMD`doesn’t need to be at the end of the `Dockerfile`. Can be anywhere after the `FROM`and still have the same result. And for the `ENV`, can be combined just like:

```dockerfile
FROM diamol/node

CMD ["node", "/web-ping/app.js"]
ENV TARGET="blog.sixeyed.com" \
 METHOD="HEAD" \
 INTERVAL="3000"

WORKDIR /web-ping
COPY app.js .
```

Then just build this like:

`docker image build -t web-ping`

Can also run the container from this image, and it behaves just like the other versions. For now is change the application code in the `app.js`and rebuild, all the steps come from the cache except the final one, which is exactly what you want, cuz that is all you have changed.

## Packaging Applications from source code into docker images

Building docker images is easy, There is one other thing you need to know to package your own apps, can also run commands inside Dockerfiles. Commands execute during the build, and any filesystem changes from the command are saved in the image layer, That makes Dockerfiles about the most flexible packing format there is.

Git is popular version control system, was 2005.. 

- Tracking code changes
- Tracking who made changes
- Coding collaboration

What does git do -- 

- Manage projects with Repositories
- Clone a project to work on a local copy
- Control and track changes with staging and commiting
- Branch and merge to allow for work on different parts and versions of a prject
- Pull the latest version of the project to a local copy
- Push local updates to the main proj.

Configure Git -- 

```sh
git config --global user.name "username"
git config --global user.email "username@test.com"
git confit --list # show the configure
```

Use `global`to set the username and e-mail for every repository on your computer. New a `index.html`, and now git is aware of the file, but has not added it to your repository. Note that files in your Git repository folder can be in one of 2 states -- 

- `Tracked`-- files that Git knows about and are added to the repository
- `Untracked`-- files are in working directory, but not added.

So, when first add files to an empty repository, they are all **untracked**. To get Git to track them, need to *stage* them, or add them to the staging environment.

### Git Staging Environment

Oneof the core functions of Git is the concepts of the staging environment and commit. As you are working, adding, editing, and removing files. Should add the files to a staging environment -- **staged** files are files that are ready to be *committed* to the repository you are working on. Can add it to the staging environment like:

```sh
git add index.html
```

Then can also stage more then one file at a time. Added some files, and then using `--all`instead of individual filenames will *stage* all changes files -- like: `git add -A`

### Git commit

Since have finished work, are ready move from stage to commit for our repo -- Adding commits keep track of our progress and changes as wok. Git consider each `commit`change point or `save point`. It is a point in the porject can go back to if you find a bug, or want to make a change.

```sh
git commit -m "First release of Hello world"
```

For this, The staging environment has been commited to our repo.

Git commit without Stage -- Sometimes, make just small changes, using the staging environment seems like a waste of time. it is possible to commit changes directly, skipping the staging environment. `-a`option will automatically stage every changed -- already tracked file fore:

```sh
git status --short # M index.html
```

- ?? -- untracked files
- A -- files added to the stage
- M -- modified files
- D -- deleted files

```sh
git commit -a -m "updated index.html with a new line"
```

git commit log -- To view the history of commits for a repository, use the `log`command -- like:

```sh
git log
```

### Git Help

If having trouble remembering commands or options for commands, you can use `git help`-- there are a couple of different ways U can use `help`command in command line like:

- `git command -help`-- see all the available options for the specific command
- `git help --all`-- see all possible commands

## Understanding Slice length and Capacity

Pretty common for go developers to mix slice length and capacity or not understand them thoroughly -- two concepts is essential for efficiently handling core operations such as slice initialization and adding elements with `append, copying, and slicing`. And In go, a slice is backed by an array, that mens that the slice’s data is stored contiguous in an array data structure, a slice also handles the logic of adding an element if the backing array is full or shrinking the backing array if it’s almost empty.

Internally, a slice holds a pointer to the backing array plus a length and a capacity -- The length is the number of elements the slice contains, whereas the capacity is the nubmer of elements in the backing array like:

`s := make([]int 3, 6)`

Accessing an element outside the langth range is forbidden. Just using the `append`function -> `s=append(s,2)`

Array is just fixed-sizing structure, can strore the new elements until element 4. When want to insert, the array is already full, go internally creates *another array* by **doubling** the capacity. Copying all the elements, and then just insreting. The slice now references the new backing array. -- if it’s no longer referenced, it’s eventually freed by the GC if allocated on the heap.

### Slice initliazation

While initializing a slice using `make`, have to provide a length and an optional cap -- forgetting to pass an appropriate vlaue for both of these parameters when it makes sense is a widespread mistake. Like:

```go
func convert(foo []Foo) []Bar {
    bars := make([]Bar, 0)
    for _, foo := range foos {
        bars = append(bars, fooToBar(foo))
    }
    return bars
}
```

This logic of creating another array cuz the current one is full is repeated multiple times when add a 3rd element, .. Assuming the input slice has 1000 elements, this alg requires allocating 10 backing and copying more then 1000. So

```go
func convert(foos []Foo) []Bar {
    n := len(foos)
    bars := make([]Bar, 0, n)
    for _, foo := range foos {
        bars = append(bars, fooToBar(foo))
    }
    return bars
}
```

And, if setting a cap and using `append`is less efficient setting a legnth and assigning to a direct index, -- like: A function called `collectAllusersKeys`need to iterate over a slice of structs to format a particular byte slisce, the resulting will be twice the length of thei nput slice like:

```go
func collectAllUserKeys(cmp Compare,)
```

Notice how more complex the code to handle the slice index.

### `nil`and empty slices

go fairly mix `nil`and empty slices, may want to use one over the other depending on the use case.

```go
func main() {
    var s []string  // empty, and nil
    s= []string(nil) // empty and nil
    s= []string{} // just empty
    s= make([]string, 0) // just empty
}
```

A `nil`slice is alo an empty slice -- only the first two are `nil`-- if have mutliple ways to initialize a slice, which option should be good -- two things to note -- 

- one of the main differences between a `nil`and an empty slice regards allocations.
- Regardless of whether a slice is `nil`, calling the `append`built-in function works.

### Not properly checking if a slice is empty

```go
func handleOperations(id string) {
    operations := getOperations(id)
    if operations != nil {
        handle(operations)
    }
}

func getOperations(id string) []float32 {
    operations := make([]float32, 0)
    if id == "" {
        return operations
    }
    return operations
}
```

For this, `getOperations()`never returns a `nil`slice, instead it returns an empty slice. For this can:

```go
func getOperations(id string) []float32 {
    operations := make([]float32, 0)
    if id == "" {
        return nil
    }
    //...
}
```

### Slice copies

the `copy`built-in allows copying elements from a source into a destination slice -- Although it is a handy built-in function, Go developers sometimes misunderstand it. Fore, in the following, create a slice and copy its elements to another slice. like:

```go
src := []int{0,1,2}
var dst []int
copy(dst, src)
```

To use `copy`effectively, it’s essential to understand that the number of elements copied to the destination slice corresonds to the minimum between -- 

- The source’s length
- the destination ‘s length

So:

```go
dst := make([]int, len(src))
copy(dst, src)
```

### Unexpeted side effects using `append`

in the following initialize `s1`, create `s2`by slicing s1 like:

```go
s1 := []int{1,2,3}
s2 := s1[1:2]
s3 := append(s2, 10)
```

We initialize an `s1`slice containing 3 elements, and s2 is created from slicing s1, then call `append`on `s3`.

Memory leaks -- Leaking cap -- for the first case, leaking cap -- fore, a message can contain 1M bytes, firt 5 represent the message type And want to stre the latest 1000 types in mmeory like:

```go
func consumeMessages(){
    for {
        msg := receiveMessage()
        storeMessageType(getMessageType(msg))
    }
}

func getMessageType(msg []byte) []byte {
    return msg[:5]
}
```

The backing array of the slice contains 1M bytes after the slicing operation, hence, if we keep 1000 message in the memory, instead of storing about 5K, hold about 1G. So, s[:5] just has s cap note that, so should write:

```go
func getMessageTypes(msg []byte) []byte {
    msgType := make([]byte, 5)
    copy(msgType, msg)
    return msgType
}
```

Cuz here perform a `copy`, `msgType`is just 5l and 5c slice regardless of the size of the message received.

## User Authentication

In this section of the book going to add some user authentication functionality to our app, so that only registered, logged-in users can create new snippets. Non-logged-in users will still be able to view the snippets.

- A user will register by visiting a form at `/user/singup`and entering their name.. Store this info in a new `users`dbs table
- A user will log in by visiting a form at `/user/login`and entering the info
- Check the dbs to see if the email and pwd they entered match one of the users in the `users`table. If there is a match, the user has *authenticated* successfully and add the relevent `id`for the user to their **session data**. using the key `authenticatedUserID`.
- When receive any subsequent requests, can check the user’s session data for a `authenticatedUserID`. If exists, know that the user has already successuflly logged in. If exists, know that the user has already successfully logged in, can keep checking this until the session expires.

Then:

- How to implement basic `signup, login logout`for users
- A secure approach to encrypting and *storing user pwd securely* in dbs by Bcrypt.
- A solid and straightforward approach to verifying that user is logged in using middleware and sessions.
- How to prevent Cross-site request Forgery (CSRF) attacks

### Routes setup

- POST & GET - `/user/signup`, `signupUser`& `signupUserForm`
- POST & GET - `/user/login`-- `LoginUserForm` & `loginUser`
- POST -- `/user/logout`-- `logoutUser`

In the `handlers.go`file and add placeholders for 5 new handler functions as follows: Then when that’s done, create the corresponding routes in the routers.go file like:

```go
// add the 5 new routes
mux.Get("/user/signup", dynamicMiddleware.ThenFunc(app.signupUserForm))
mux.Post("/user/signup", dynamicMiddleware.ThenFunc(app.signupUser))
mux.Get("/user/login", dynamicMiddleware.ThenFunc(app.loginUserForm))
mux.Post("/user/login", dynamicMiddleware.ThenFunc(app.loginUser))
mux.Post("/user/logout", dynamicMiddleware.ThenFunc(app.logoutUser))
```

Finally, need to just update the base.layout.html file to add the navigation items for the new pages like:

```html
<nav>
    <!-- update the navigation to include the signup, login, and logout-->
    <div>
        <a href="/">Home</a>
        <a href="/snippet/create">Create snippet</a>
    </div>
    <div>
        <a href="/user/signup">Signup</a>
        <a href="/user/login">Login</a>
        <form action="/user/logout" method="post">
            <button>Logout</button>
        </form>
    </div>
</nav>
```

### Creating a Users Model

Now that the routes are just setup, need to create a new `users`dbs table and a dbs model to access it. Start by connecting to MySQL from terminal as the root and execute the following sql statement set up the users table like:

```sql
create table users
(
    id              INTEGER      NOT NULL PRIMARY KEY AUTO_INCREMENT,
    name            VARCHAR(255) not null,
    email           VARCHAR(255) not null,
    hashed_password CHAR(60)     NOT null,
    created         DATETIME     not null,
    active          BOOLEAN      not null default TRUE
);

Alter table users
    add constraint users_uc_email UNIQUE (email);
```

There is a couple of things worth pointing out about this table -- 

- The `id`field is an auto-incrementing integer field and the PK for the table.
- for the `hashed_password`-- storing hashes of the users passwords in the dbs. and this version will always be exactly 60 characters long.
- Also added a `UNIQUE` constraint on the `email`column and named it `users_uc_email`-- ensures that we won’t end up with two users who have the same email address.
- Also, an `active`column which use to contain the status of the user account.

### Building the Model in Go

Set up a model so that can easily work with the new `users`table, follow the same pattern that we used earlier in the book for modeling access to the snippets table.

```go
var (
	ErrNoRecord = errors.New("models: no matching record found")

	// ErrInvalidCredentials add a new error, use this later if a user tries to log in
	// just with incorrect email address or password
	ErrInvalidCredentials = errors.New("models: invalid credentials")

	// ErrDuplicateEmail Add a new error use this later if a user
	// tries to signup with an email that's already in use
	ErrDuplicateEmail = errors.New("models: duplicate email")
)

// User Define a new User type, notice how the names and types align
// with the columns in the dbs tble
type User struct {
	ID             int
	Name, Email    string
	HashedPassword []byte
	Created        time.Time
	Active         bool
}
```

Then, the types has been set up, need to make the actual dbs model, create a new file named: users.go:

```go
type UserModel struct {
	DB *sql.DB
}

// Insert will use the Insert method to add a new record to the users table
func (m *UserModel) Insert(name, email, password string) error {
	return nil
}

// Authenticate verifies whether a user exists with the provided email address
// and password, will return the relevant user id
func (m *UserModel) Authenticate(email, password string) (int, error) {
	return 0, nil
}

// Get fetches details for a specific user based on the user id
func (m *UserModel) Get(id int) (*models.User, error) {
	return nil, nil
}
```

Final stage is to add a new field to the app struct so that can make this model available to our handlers like:

```go
session.Secure = true
app := &application{
    //...
    users: &mysql.UserModel{DB:db}
}
type application struct {
    //...
    users *mysql.UserModel
}
```

Make sure that all the files are all saved, then go and try to run the app.

### User signup and Pwd Encryption -- 

Before can log in, first need a way for them to sign up for an account, cover how to do that -- like `singup.page.html`flile containing the following markup like:

```html
{{template "base" .}}

{{define "title"}}Signup{{end}}

{{define "main"}}
    <form action="/user/signup" method="post" novalidate>
        {{with .Form}}
            <div>
                <label>Name:</label>
                {{with .Errors.Get "name"}}
                    <label class="error">{{.}}</label>
                {{end}}
                <input type="text" name="name" value="{{.Get "name"}}">
            </div>

            <div>
                <label>Email:</label>
                {{with .Errors.Get "email"}}
                    <label class="error">{{.}}</label>
                {{end}}
                <input type="email" name="email" value="{{.Get "email"}}">
            </div>

            <div>
                <label>Password:</label>
                {{with .Errors.Get "password"}}
                    <label class="error">{{.}}</label>
                {{end}}
                <input type="password" name="password">
            </div>

            <div>
                <input type="submit" value="Signup">
            </div>

        {{end}}
    </form>
{{end}}
```

# Bootstrapping Crash courses

Every app has a main entry point -- this app was built using Ng CLI -- run this app by calling the command:
`ng serve`-- ng will looka the file `angular.json`to find the entry point to our app -- trace how `ng`finds the componetns we just built -- at a high level -- looks like this:

- `angular.json`-- specifies a main file which is in this case `main.ts`
- `main.ts`-- the entry-point for our app and it bootstraps our app module.
- Use the `AppModule`to bootstrap the app. is specified in src/app/app.module.ts.
- AppModule specifies which componetns 

```python
url = 'https://raw.githubusercontent.com/justmarkham/DAT8/master/data/chipotle.tsv'
import io, requests
s = requests.get(url, proxies={'https': 'http://localhost:7890'}).text

df = pd.read_csv(io.StringIO(s), sep='\t')

# what is the most-ordered item
c = df.groupby('item_name').sum(numeric_only=True)
c['quantity'].sort_values().tail(1)
df.groupby('choice_description').sum(numeric_only=True)['quantity'].sort_values().tail(1)
df.quantity.sum()
df['item_price']=df['item_price'].str[1:].astype(np.float64)
# or use like this:
dollarizer = lambda x: float(x[1:-1])
df.item_price = df.item_price.apply(dollarizer)

# sum
revenue = (df['quantity']*df['item_price']).sum()
np.round(revenue, 2)
# count
df['order_id'].value_counts().count()
# what is the average per order:
df['revenue']=df['item_price']*df['quantity']
grouped= df.groupby('order_id').sum(numeric_only=True)
grouped.mean()['revenue']

# how many different name
df['item_name'].value_counts().count()
```

### declarations

`declarations`specifies the component that are defined in this module, this is an important idea -- Have to declare components in a `NgModule`before you can use them in your templates. Can think of an NgModule a bit like a package and declarations states what componetns are owned by this module.

imports -- `imports`declare which dependenies the module has. And `providers`is used for DI. And `bootstrap`tells Ng that when this module is used to bootstrap an app, need to load the `AppComponent`as the top-level component.

```html
<form class="ui large form segment">
  <h3 class="ui header">Add a Link</h3>

  <div class="field">
    <label for="title">Title:</label>
    <input name="title" id="title">
  </div>
  
  <div class="field">
    <label for="link">Link:</label>
    <input name="link" id="link">
  </div>
</form>
```

### Adding interaction -- 

Now have the form with input tags but don’t have any way to submit the data. Want to call a function to create and add a link do this, by:

```html
<form class="ui large form segment">
  <h3 class="ui header">Add a Link</h3>

  <div class="field">
    <label for="title">Title:</label>
    <input name="title" id="title" #newtitle>
  </div>

  <div class="field">
    <label for="link">Link:</label>
    <input name="link" id="link" #newlink>
  </div>
</form>

<button (click)="addArticle(newtitle, newlink)"
        class="ui positive right floated button">
  Submit link
</button>

```

```ts
export class AppComponent {
  addArticle(title: HTMLInputElement, link:HTMLInputElement):boolean {
    console.log(`Adding article title: ${title.value}, and linke: ${link.value}`);
    return false;
  }
}
```

With the `addArticle()`function added to the `AppComponent`and the `(click)`event added to the `<button />`elemeent, this func will be called when the button is clicked.

Just noticed that the input tags we used the `#`to tell ng to assign those tags to a local variable. By adding `#newtitle`and `#newlink`to appropraite `<input>`elements, can pass them as variables into the `addArticle()`.

Binding `inputs`to values -- Notice in first input tag we have the following like:

`<input name="title" #newtitle>`-- this markup tells Ng to bind the `<input>`to the variable `newtitle`-- syntax is called a *resolve* -- the effect is that this makes the variable `newtitle`avaialble to the expressions with the view. `newtitle`is now an `object`that represents this `input`DOM element -- cuz `newtitle`is an object, that means we get the value of the input tag using `newtitle.value`.

### Binding actions to events

Our `button`tag add the attribute (click) to define what should happen when the button is clicked. Add the component -- now have a form to submit new articles, aren’t showing the new articles anywhere, cuz every article submitted is going to be displayed as a list on the page, this is the perfect candidate for a new component like:

```html
<div class="four wide column center aligned votes">
  <div class="ui statistic">
    <div class="value">{{votes}}</div>
    <div class="label">
      Points
    </div>
  </div>
</div>

<div class="twelve wide column">
  <a class="ui large header" href="{{link}}">{{title}}</a>
  <ul class="ui big horizontal list voters">
    <li class="item">
      <a href (click)="voteUp()">
        <i class="arrow up icon"></i>
        upvote
      </a>
    </li>

    <li class="item">
      <a href (click)="voteDown()">
        <i class="arrow down icon"></i>
        downvote
      </a>
    </li>
  </ul>
</div>
```

```ts
@Component({
  selector: 'app-articles',
  templateUrl: './articles.component.html',
  styleUrl: './articles.component.css'
})
export class ArticlesComponent {
  @HostBinding('attr.class') cssClass = 'row';
  votes: number;
  title: string;
  link: string;

  constructor() {
    this.title = "Angular";
    this.link = 'http://angular.io';
    this.votes = 10;
  }

  voteUp() {
    this.votes++;
  }

  voteDown() {
    this.votes--;
  }
}
```

Just note that the`@HostBinding`-- `cssClass`want to apply to the host this component. In Ng, a component host is just the element this component is attached to. Can set properties on the host element by using the `HostBinding()`decorator -- In this case, are asking Ng to keep the value of the host elements class to be in sync with the property `cssClass`. By using `HostBinding()`the host element we want to set the class attribute to have a `row`class -- For this, using the `HostBinding()`decorator is nce cuz it means can encapsulate the `app-article`