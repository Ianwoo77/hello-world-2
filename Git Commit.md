# Git Commit

Since have finished our work, are ready to stage to `commit`for our repo. Adding commits *keep track* of our prgress, and changes as we wori. Git considers each commit change point or *save point*. It is a point in the project you can go back to if you find a bug, or want to make a change. When commit, should **always** includes a message. like:

```sh
git commit -m "First release of Hello"
```

Without stage -- Sometimes, just make small changes, using the staging seems like a waste of time. It is possible to commit changes directly, just skipping the staging environment -- the `-a`option will automatically stage every changed, already tracked file.

```sh
git commit -a -m "updated.." # skipping the staging is not generally recommended
# and the git commit log
git log
```

### Git Branch

In git, a `branch`is new/separate version of the main repository -- say you have a large proj, and you need to update the designed on it. without git -- need-- make copies of all files, then start working with the design and find that code depend on code in other files.. Make copies of the denpendant files as well, Save all, working on the unrelated error..

With Git -- 

- With a new branch called new-design, edit the code directly without impacting the main branch
- EMERGENCY! fore, there is an unrelated error somewhere else in in the proj that needs to be fixed
- Create a new branch from the main proj called small-error-fix
- Fixt the unrelated error and merge the small -error-fix branch with the main branch
- go back to the new-design branch

New git branch -- add some new features to the index.html like: We are now working in the local repository, do not want to disturb or possibly wreck the main proj.

```sh
git branch hello-world-images
git branch # show all
```

`*`beside master speciries what we are currently on that `branch`. Moving from the current, just to the one specified at the end of the command like:

```sh
git checkout hello-world-images # switch to branch ..
```

Fore, add an image to the working folder and a line of code in the `index.html`file like:

```html
<div>
    <img src="img_hello_world.jpg"
         alt="hello" style="width:100%;max-width: 960px;">
</div>
```

We have made changes to a file and added a new file in the working directory. 

```sh
git status
```

So, let’s go through what happens here -- 

- There are changes to our `index.html`but the file is not staged for commit
- jpg file is not tracked.

Then:

```sh
git add --all
# then just commit that
git commit -m "Added image to proj"
```

Now have a new branch, that is just different from the master `branch`.

**NOTE:**, using the `-b`option on `checkout`will create a new branch, and move to it, if not exist

#### Switch between branches

now let’s see just how quick and easy it is work with different branches -- and how well it works -- we are currently on the branch, added an image to this branch, so let’s list the file in the current directory like:  see :

```sh
git checkout master
```

for this, jpg file is no longer there, if open the html, can se the code reverted to waht it was before the alternation.

Emergency Branch -- Now image that we are not yet done with `hello-world-images`, but need to fix an error on master, and don’t want to mess with master directly, and i do not wan to mess with the img. Can:

```sh
git checkout -b emergency-fix #switched to a new branch
```

Now have created a new branch **from master** -- and changed to it, can now safely fix the error without districuting the other branches. Just fix the imaginary error like:

### Git Branch merge

For now have the emergency fix ready, let’s merge the master and emergency-fix branches.

```sh
git branch -d emergency-fix # deleted branch
```

Merge conflict -- Now cna move over to hello-world-images and keep working.

```html
<div>
    <img src="hello_git_jpg.jpg"
         alt="git" style="width:100%;max-width: 640px;">
</div>
```

```sh
git add --all
git checkout master
git merge hello-world-images
```

The merge jsut failed, as there is conflict between versions for index.html, check the status like: This confirms that there is a conflicit in index.html -- but the image files are ready and staged to committed. Can see the differences between versions and edit it just.

```sh
git add --all
git commit -m "fixing"
git branch -d hello-world-images
```

### Who needs a build server

Building software on laptop is sth U dof for a local development, but when you are working on a team there is more rigorous delivery process. There is a shared source control system like Git where everyone pushes their code changes. And there is typically a separate server that builds the software when changes are pushed.

Start with a simple example, cuz there are a couple of new things to understand in this process like:

```dockerfile
FROM diamol/base as build-stage
RUN echo 'Building...' > /build.txt

FROM diamol/base as test-stage
COPY --from=build-stage /build.txt /build.txt
RUN echo 'Testing...' >> /build.txt

FROM diamol/base
COPY --from=test-stage /build.txt /build.txt
CMD cat /build.txt
```

This is just called a multi-stage Dockerfile, cuz there are just several stages to the build. Each stage starts with a `FROM`instruction, and U can optionally give stages a name with the `AS` parameter. **Each stage runs independently**, but can copy files and directories from prevous stages, using the `COPY`instruction wtih the `--form` argument, which tells Docker to copy files from an earlier stage in the Dockerfile. Rather than from the filesystme of the host. FORE, generated a file in the build stage, copy it into the test stage, and then copy the file from the test stage into the final stage. There is one new instruction here, `RUN`which using to write files.

There is one new instruction -- the `RUN`instruction executes a command inside a container during the build, and any output from that command is saved in the image layer. Can execute anything output from that command is saved in the image layer -- but the commands you want to run need to just exist in the Docker image that you are using in the `FROM`instruction.

```sh
docker image build -t multi-stage .
```

See that the build executes the steps in the order of the Dockerfile, which gives the sequential build through the stages. In the build stage use a base image that has your app’s build tools installed, copied in the source code from your host machine and run the `build`. This approach makes your app truly portable.

All the major app frameworks already have public images on Docker Hub with the build tools installed, and there are separate images with the app runtime.

## Slice and Pointers

Have seen that slicing can cause a leak cuz of the slice capacity -- but what about the elements -- which are still part of the backing array but outside the length range. like:

```go
type Foo struct {
    v []byte
}
```

Want to check the memroy allocations after each step as follows -- 

- Allocate a slice of 1000 `Foo`elements
- Iterate over eah `Foo`element, and for each one, allocate 1MB for v slice
- Call `keepFirstTwoElementsOnly`whcih returns only the first two using slicing then call a `GC`.

```go
func main() {
    foos := make([]Foo, 1000)
    printAlloc()
    
    for i:=0; i<len(foos); i++ {
        foos[i]= Foo {v: make([]byte, 1024*1024)}
    }
    printAlloc()
    
    two := keepFirstTwoElementsOnly(foos)
    runtime.GC()
    printAlloc()
    runtime.KeepAlive(two)
}

func keetFirstTwoElementOnly(foos []Foo) []Foo {
    return foos[:2]
}
```

Noticed that the `GC`didnot collect the remaining 998 elements. Cuz `Foo`just contains a slice, the remaining 998 and their slice *aren’t reclaimed* -- therefore, even though these 998 elements can’t be accessed, they stay in memory.

```go
func keepFirstTwoOnly(foos []Foo) []Foo {
    res := make([]Foo, 2)
    copy(res, foos)
    return res
}
```

There is a second option if we want to keep the underlying capacity of 1000 elements, which is to mark the slices of the remaining elements explicitly as `nil`. like:

```go
func keepFirstTwoElementsOnly(foos []Foo) []Foo {
    for i :=2; i<len(foos) ; i++ {
        foos[i].v = nil
    }
    returns foos[:2]
}
```

### Ineffecient map initialization

This discusses an issue smilar to one saw with slice initialization, but using maps -- need to knw the basic regarding how maps are implemented in Go to understand why tweaking map initialization is important.

-- A *map* provides an unordered collection of key -- value pairs in which all the keys are distinct, in go, a map is based on the hash table data structure, internally, a hash table is an array of buckets, and each bucke is just a pointer to an array of key. In thec case of insertion into a bucket that is already full -- Go just creates another bucket of 8 elements and links the prevous bucket to it. Regarding reads.. Go must calculate the corresponding array index.

#### Initialization

fore:

```go
m := map[string] int {
    "1": 1, "2": 2, "3": 3,
}
```

Internally, this map is backed by an array consisting of a single entry -- a single bucket, Finding a key would mean -- going over thousands of buckets. This is why map should be able to grow automatically to cope with the number of elements. When a map grows, it doubles its number of buckets -- 

- The average number of items in the buckets is greater than a constant value. 6.5 by default
- Too many bucket have overflowed

When a map grows, all the keys are dispatched again to all the buckets. The idea is just similar for maps, indeed, can use the `make`built-in function to provide an initial size when creating a map, if want to initialize a map that will contain 1 M elements, it can be done this way like : `m := make(map[string]int, 1000000)`

By specifying a size like this, provide a hint about the number of elements expected to go into the map. Internally, the map is created with an appropriate number of buckets to store elements.

Also, specifying a size n doesn’t mean making a map with a maximum number of n elements -- can still add more than n elements if needed. like:

### Maps and memory leaks

```go
// design sceranio like:
m := make(map[int][128]byte)
```

Then:

```go
n:= 100000
m := make(map[int][128]byte)
printAlloc()
for i:=0; i<n; i++{
    m[i]=randBytes()
}
printAlloc()
for i:=0; i<n; i++ {
    delete(m, i)
}
runtime.GC()
runtime.KeepAlive(m)
```

### Comparing values incorrectly

```go
type customer struct {
    id string
}
func main(){
    cust1 := ...
    cust2 :=...
    fmt.Println(cust1==cust2)
}
```

Need to note that comparing these two `customer`struct is valid operation in Go, and it will print `true`-- but if:

```go
type customer struct {
    id string
    operations []float64
}
func main(){
    fmt.Println(cust1==cust2)
}
```

The problem relates how the == and != work -- These operators don’t work with slices or maps. So, what are the options if we have to compare two slices -- using the **reflection**. In go , can use the `reflect.DeepEqual`. This function reports whether two elements are deeply equal by recursively traversing two values. so:

```go
cust1 := customer {id: "x", operation: []float64{1.}}
cust2 := customer {id: "x", operation: []float64{1.}}
fmt.Println(reflect.DeepEqual(cust1, cust2))
```

For this, even though the `customer`struct contains non-comparable types, it operates as expected.

## User signup and Password Encryption

Before can log in any users to our `SnippetBox`app, first need a way for them to sign up for an account, cover how to do that in this -- Fir the signup form we are using exactly the same form structure that we used earlier. Then look this up to the `signupForm`handler like:

```go
func (app *application) createSnippetForm(w http.ResponseWriter, r *http.Request) {
	app.render(w, r, "create.page.html",
		&templateData{Form: forms.New(nil)})
}
```

### validating the User input

When this form is submitted the data will end up being posted to the `signupUser`handler that we made -- The first task of this handler will be validate the data and make sure that it is sane and sensible before insert it into the dbs.

1. Check for blank
2. Sanity check the format for email
3. Ensure the length of the password
4. Makre sure that the email isn’t already in use

```go
func (f *Form) MinLength(field string, d int) {
	value := f.Get(field)
	if value == "" {
		return
	}
	if utf8.RuneCountInString(value)<d {
		f.Errors.Add(field, fmt.Sprintf("this field is too short" +
			" (min is %d characters)", d))
	}
}

// MatchesPattern check that a specific field in the form matches a regexp
func (f *Form) MatchesPattern(field string, pattern *regexp.Regexp) {
	value := f.Get(field)
	if value =="" {
		return
	}
	if !pattern.MatchString(value) {
		f.Errors.Add(field, "This field is invalid")
	}
}

//.. the EmailRx pattern:
var emailRegexp = regexp.MustCompile("^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$")

```

Then just head over to the `handlers.go`file and add some code to process the form and run the validation checks like:

```go
func (app *application) signupUser(w http.ResponseWriter, r *http.Request) {
	// parse the form data
	err := r.ParseForm()
	if err != nil {
		app.clientError(w, http.StatusBadRequest)
		return
	}

	// validate the form contents using the form helper
	form := forms.New(r.PostForm)
	form.Required("name", "email", "password")
	form.MaxLength("name", 255)
	form.MaxLength("email", 255)
	form.MatchesPattern("email", forms.EmailRx)
	form.MinLength("password", 5)

	// if there are any errors, re-display the signup form
	if !form.Valid() {
		app.render(w, r, "signup.page.html", &templateData{Form: form})
		return
	}

	fmt.Fprintln(w, "Create a new user...")
}
```

All that remains now is the fourth validation check. And cuz we’ve got a `UNIQUE`constraint on the `email`field in dbs, it’s already guaranteed that won’t end up with two users in the dbs who have the same email address.

### A brief instruction to Bcrypt

And, if your dbs is ever compromisted by an attacker, it’s hugely important that it doesn’t contain the plain-text versions of your user’s passwords. It’s just good practice -- really -- to just store a *one-way* hash of the password, derived wtih a computationally expensive key-derivation function such as.. Go has a good implemenrations of all 3 algorithms, but a plus-point of the `brcypt`implemenration is that it includes some helper specially designed for hashing and checking passwords.

And there are two functions in the brcypt package that use in this book -- first is the `brcypt.GenerateFromPassword()`which lets us create a hash of a given plain-text password like:

`hash, err := brcypt.GenerateFromPassword([]byte("password"), 12)`

The second that passed in indicates the cost, 4 to 31. 2^12 iterations. On the flip side, can check that a plain-text password matches a particular hash using the `brcypt.CompareHashAndPassword()`function like so:

```go
hash := []byte("....")
err := brcypt.CompareHashAndPassword(hash, []byte("my password"))
```

Will return `nil`if the plain-text password matches the particular hash.

### Storing the user Details

So the next stage is up update the `UserModel.Insert()`method so that it creates a new record in the `users`table containing the vlidated name, email, and hashed password. This will be interesting for two -- want to store the bcrypt hash of the password, also need to manage the potential error, fore, caused by a duplicate email.

All errors returned just by `MySQL`have a particular code, which can use to triage hat has caused the error. In the case of the duplicate email, the error code used be 1062 like:

```go
func (m *UserModel) Insert(name, email, password string) error {
	// Create a bcrypt hash of plain-text
	hashPassword, err := bcrypt.GenerateFromPassword([]byte(password), 12)
	if err != nil {
		return err
	}

	stmt := `INSERT INTO users (name, email, hashed_password, created)
				values (?, ?, ?, UTC_TIMESTAMP())`

	// use the Exec() method to insert the user details
	_, err = m.DB.Exec(stmt, name, email, string(hashPassword))
	if err != nil {
		// if this returns error, we use the `errors.As()` function to
		// check whether the error has the type *mysql.MySQLError.
		// if does, the error will be assigned to the variable.
		var mySQLError *mysql.MySQLError
		if errors.As(err, &mySQLError) {
			if mySQLError.Number == 1062 && strings.Contains(mySQLError.Message,
				"users_uc_email") {
				return models.ErrDuplicateEmail
			}
		}
		return err
	}
	return nil
}
```

Can just finish this all off by updating the `singupUser`handler like so:

```go
// try to create a new user record in the dbs, if the email already exists
// add an error message to the form and re-display it
err = app.users.Insert(form.Get("name"), form.Get("email"),
                       form.Get("password"))
if err != nil {
    if errors.Is(err, models.ErrDuplicateEmail) {
        form.Errors.Add("email", "Address is already in use")
        app.render(w, r, "signup.page.html", &templateData{Form: form})
    } else {
        app.serverError(w, err)
    }
    return
}

// otherwise, add a confirmation flash message
app.session.Put(r, "flash", "your signup was successful, please login")
// And redirect the user to the login page.
http.Redirect(w, r, "/user/login", http.StatusSeeOther)
```

At this point, it’s worth opening the dbs and looking at the contents of the `users`table.

### Additional info

Using dbs Bcrypt implementation -- Some dbs provide built-in functions that you can use for password-hasing and verification instead of implementing your own in Go. but it’s probably a good idea to aoivd using these -- 

- They tend to be vulnerable to side-channel timing attacks due to string comparison time not being constant
- Unless U are careful, sending a plain-text to dbs risks the pwd being accidentally recorded in one of your dbs logs.

#### Alternatives for checking Email duplicates

Understand that the code in `UserModel.Insert()`method isn’t very pretty, and that checking the error returned by the `MySQL`feels a bit fraky. An alternative would to be add an `UserModel.EmailToken()`method to the model checks to see if a user with a specific email already exists. However, this would introduce a race condition to our app and if two users try to sign up with the same email address at exactly the same time, both submissions will pass the validation check but ultimately only one `INSERT`into the `MYSQL`dbs will succeed.

```python
import io, requests
url = 'https://raw.githubusercontent.com/justmarkham/DAT8/master/data/u.user'
rep = requests.get(url, proxies={'https': 'http://localhost:7890'}).text
df = pd.read_csv(io.StringIO(rep), sep="|", index_col='user_id')
df.shape[1]
# how many different occupations are in this data set
df.occupation.nunique()
# what is the most frequent occupation
df.occupation.value_counts().head(1).index[0]
# summarize all the columns
df.describe(include='all')
# summarize only the occupation column
df.occupation.describe()
# what it the mean age of users
round(df.age.mean())
# what is the age with least occurrence
df.age.value_counts().tail()
```

Ex2:

```python
url = 'https://raw.githubusercontent.com/justmarkham/DAT8/master/data/chipotle.tsv'
import io, requests
df = pd.read_csv(io.StringIO(
    requests.get(url, proxies={'https': 'http://localhost:7890'}).text
), sep='\t')

# how many products cost more than $10.00?
prices = df.item_price.str[1:].astype(float)
df['item_price']=prices
filtered= df.drop_duplicates(['item_name', 'quantity', 'choice_description'])
# select only the products with quantity equals to 1
chipo_one_prod= filtered[filtered.quantity==1]
df.query('item_price>10')

# what is the price of each item -- 
df[(df['item_name']=='Chicken Bowl') & (df['quantity']==1)]
# select only the products with quantity to 1

# sort by name of the item like:
df.sort_values(by= 'item_name')

# what was the quantity of most expensive item ordered?
df[df['item_price']==df['item_price'].max()]

# How many times was a Veggie Salad Bowl Ordered?
df[df['item_name']=='Veggie Salad Bowl'].count()
len(df[df.item_name=="Veggie Salad Bowl"])

# how many times did someone order more than one canned soda
len(df[(df.item_name=='Canned Soda') & (df.quantity>1)])
```

# Creating Definition class

```ts
export class ArticleComponent implements OnInit {
    @HostBinding('attr.class') cssClass='row';
    votes: number;
    title: string;
    link: string;
    // ctor and others.
}
```

- `cssClas`-- the CSS class we want to apply the `host`of this component
- `votes`-- a number representing the sum of all upvotes, minus the downvotes
- `title`-- a string holding the title of the article
- `link`-- a `string`holding the URL of the article.

Using `HostBinding()`the *host element* want to set the `class`to have a `row`.  Using the `HostBinding()`nice cuz it means we can encapsulate the `app-article`markup within our component. That is, don’t have to both use an `app-article`tag and require a `class=row`in the markup of the parent view. By using this, able to configure our host element from *within* the component.

For now, clicking on the `vote up`or down links will cause the page to reload instead of updating the article list. For JS, by default, propagates the click event to all the pareent componetns cuz the `click`event is propagated to parents. To fix this, just need to make the click to return `false`, this just ensures the browsers won’t try to refresh the page.

### Rendering multiple rows

Right now we only have one article on the page and there is no way to render more. Unless we paste another.. So Creating an article class -- A good practice when writing Ng code is to try to isolate the data structures from the component code. Create a data structure that represents a single article just like:

```ts
export class Article {
  title: string;
  link: string;
  votes: number;

  constructor(title: string, link: string, votes?: number) {
    this.title = title;
    this.link = link;
    this.votes = votes || 0;
  }
}
```

Then update the `ArticleComponent`code to use our new `Article`class -- just like:

```ts
export class ArticlesComponent {
  @HostBinding('attr.class') cssClass = 'row';

  article: Article;
  constructor() {
    this.article= new Article(
      'Angular', 'http://angular.io', 10
    );
  }

  voteUp():boolean {
    this.article.votes++;
    return false;
  }

  voteDown():boolean {
    this.article.votes--;
    return false;
  }
}
```

Then just modify the view like:

`<div class="value">{{article.votes}}</div>`

### Storing multiple Articles

Write code that allows to have a list of mutliple `Article`s -- just like:

```ts
constructor() {
    this.articles= [
        new Article('Angular', 'http://angular.io', 3),
        new Article('Fullstack', 'http://fullstack.io', 2),
        new Article('Angular HomePage', 'http://angular.io', 1),
    ];
}
```

Configuring the `ArticleComponetn`with `inputs`-- 

now that have a list of models, can pass them to the component -- `Input`s used. Just need to:

`<app-article [article]='article1'></app-article>`

```ts
@Input() article!: Article
constructor() {
}
```

Rendering a list of articles -- like:

```html
<div class="ui grid posts">
  <app-articles *ngFor="let article of articles"
                [article]="article"></app-articles>
</div>
```

## How Ng works

Application -- an Ng Application is nothing more than a tree of components -- At the root of that tree, the top level component is the application itself, and that is what the browser will render when booting the app. one of the great things about the components is that they are just *Composable*.

### product model

One of the key things to realize about Angular is that it doesn’t prescribe a particular model library -- Ng is just flexible enough to support many different kinds of models.

```ts
export class Product {
  constructor(
    public sku: string,
    public name: string,
    public imageUrl: string,
    public department: string[],
    public price: number
  ) {
  }
}
```

### Components -- 

Are just the fundamental building block of Ng applications -- the application itself is just the top-level Component, then we break our app into smaller child components like: be using Components a lot, so worth looking at them more closely -- 

- component decorator
- a view
- a controller

The `@Component`decorator is where you configure your component. One of the primary roles of the `@Component`decorator is to configure how the outside world will interact with your component. Just change the app: Want to support user interaction in the app. The user might select a particular product to view more info about the product. Add some function to the `AppComponent`to handle what happens when a new product is selected define a new function like:

```ts
productWasSelected(product: Product) : void {
    console.log('product clicked', product);
}
```

Then list products usingt he `<products-list>`like:

```html
<div class="inventory-app">
  <product-list
    [product-list]="products"
    (onProductSelected)="productWasSelected($event)">
  </product-list>
</div>
```

(parens) handle outputs -- In ng, you send data out of components via outputs. In this case like:

`<product-list (OnProductSelected)="productWasSelected($event)">`

we are saying that we want to just listen on the `OnProductSelected`output from the product-list component -- which:

- (onProductSelected) -- is the name of the output we want to listen on.
- `$event`is jsut special variable represents the thing emitted on. i.e. sent to the output.

The `ProductListcomponent`-- Now that have our top-level appliation component, write the component like:

```ts
@Component({
  selector: 'app-product-list',
  templateUrl: './product-list.component.html',
  styleUrl: './product-list.component.css'
})
export class ProductListComponent {
  @Input() productList!: Product[];
  @Output() onProductSelected!: EventEmitter<Product>();
}
```

Component inputs -- `Inputs`specify the parameters we export our component to receive, to diignate an input, use the `@Input`decorator on a component class property-- when we specify that a component takes an input, just like:

```ts
class MyComponent {
    @Input() name:string;
    @Input() age: number;
}
```

The `name`and `age`inputs map to the `name`and `age`properties on instantces of the `MyComponent` class. Notice that the attribute `name`matches the input `name`-- like:

```html
<my-component [shortName]="myName" [oldAge]="myAge"></my-component>
```

for this:

```ts
class MyComponent{
    @Input("shortName") name : string;
}
```

#### Component outputs

When want to send data from your component to the outside world, use output bindings -- Say a component has a button need to do sth when that button is clicked. The way the `(click)`output of the button to a method declared on our component’s controller, do that using the `(output)="action"`notation. like: In the (click) example, the event is *internal* to the component. fore:

```ts
@Component ({
    //...
    template: `{{value}}
<button (click)="increase()">Increase</button>`
})class Counter {
    //...
    increase() {
        this.value++;
        return false;
    }
}
```

In this, saying that every time the first button is clicked, want the `increase()`method on the controller to be invoked. There is no effect that leaves component. When creating our own components need, to expose public events. 

### Emitting Custom events

Want to create a component that emits a custom event, --

1. Specify outputs in the `@Component`
2. Attach an `EventEmitter`to the output proprety
3. Emit an event from the `EventEmitter`just like:

```ts
class SingleComponent {
    @Output() putRingOnit: EventEmitter<string>;
    constructor(){
        this.putRingOnit= new EventEmitter();
    }
    liked(): void {
        this.putRingOnit.emit("nono")
    }
}
```

```html
<button (click)="liked()">
    Like it
</button>
```

```html
<div>
    <single_component (putRingOnit)="ringWasPlaced($event)"></single_component>
</div>
```

```ts
class ClubComponent{
    ringWasPlaced(message: string) {
        console.log(message);
    }
}
```

Writhing Controller Class -- like:

```html
<div class="inventory-app">
  <app-product-list
    [productList]="products"
    (onProductSelected)="productWasSelected($event)">
  </app-product-list>
</div>
```

```ts
export class ProductListComponent {
  @Input() productList!: Product[];
  @Output() onProductSelected: EventEmitter<Product>;

  private currentProduct?: Product;
  constructor() {
    this.onProductSelected= new EventEmitter<Product>();
  }
}
```

Then, writing the `ProductListComponent`view Template like -- 

```html
<div class="ui items">
  <product-row
    *ngFor="let myProduct of productList"
    [product]="myProduct"
    (click)="clicked(myProduct)"
    [class.selected]="isSelected(myProduct)"></product-row>
</div>
```

Here are using the `product-row`tag, which comes from the `ProductRow`component, which will define. Using the `ngFor`to iterate over each product in the productList.

```ts
export class ProductListComponent {
  @Input() productList!: Product[];
  @Output() onProductSelected: EventEmitter<Product>;

  private currentProduct?: Product;

  constructor() {
    this.onProductSelected = new EventEmitter<Product>();
  }

  clicked(product: Product) {
    this.currentProduct = product;
    this.onProductSelected.emit(product);
  }

  isSelected(product: Product): boolean {
    if (!product || !this.currentProduct)
      return false;
    return product.sku === this.currentProduct.sku;
  }
}
```

Then for the `ProductRowComponent`-- display our product -- wiill have its own template, but also be split up the three smaller components like: Then look at the template like:

```html
<app-product-image [product]="product"></app-product-image>

<div class="content">
  <div class="header">{{product.name}}</div>
  <div class="meta">
    <div class="product-sku">SKU #{{product.sku}}</div>
  </div>
  
  <div class="description">
    <app-product-department [product]="product"></app-product-department>
  </div>
</div>
<app-price-display [price]="product.price"></app-price-display>
```

And the `ProductImageComponent`-- like:

```ts
export class ProductImageComponent {
  @Input() product!: Product;
  @HostBinding('class') cssClass='ui small image';
}
```

```html
<img class="product-image" [src]="product.imageUrl">
```

The `ProductDisplayComponent` like:

`<div class="price-display">\${{price}}</div>`

Then the `ProductDepartmentComponent`-- 

```html
<div class="product-department">
  <span *ngFor="let name of product.department; let i=index">
    <a href="#">{{name}}</a>
    <span>{{i < (product.department.length - 1) ? '>' : ''}}</span>
  </span>
</div>
```

