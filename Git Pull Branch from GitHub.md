# Git Pull Branch from GitHub

continue working on new branch in our local Git

```sh
git pull
# now main branch is up todate. see there is a new branch
git status
git branch
git branch -a # show all branch including remote
git branch -r # show remote branches only
```

### Push a Branch to GitHub

try to create a new local branch, and push that to Github like:

```sh
git checkout -b update-readme
```

Then make some changes to the `Readme.md`file, just add a new line fore. So check the status of the current: then:

```sh
git status
git add README.md
git status
git commit -m "updated readme for Github branches"
git push origin update-readme
```

In the Github, can now see the changes and can merge them into the master if we approve that.

### Templating Engines

Templating engines help us dynamically render HTML pages in contrast to just having fixed static pages which in the earlier chapter gives us a problem that have to duplicate the nav bar code for all static pages. Just refactor our app to use a templating engine that allows us to abstract our app into diferent layout files so don’t repeat common code.

There are many templating engines out there, using EJS cuz it is ont of the more popular templating engines and is made by created Express.

```sh
npm install ejs --save
```

The `--save`option is to have the dependencies listed in our package.json so someone else can install the dependencies later if give them the proj. They will only run `npm install`with no arguments.

And the `-dev`is specify we install some package for development purpose only.

EJS is a simple templating just lets us generate theml with plain js in simple straightforward script tag `<%= ... %>`.

```js
app.get('/', (req, res)=> {
    res.render('index');
})

app.get('/about', (req, res)=>{
    res.render('about')
});

app.get('/contact', (req, res)=> {
    res.render('contact')
});

app.get('/post', (req, res)=> {
    res.render('post')
})
```

Thus, change the file extension of `*.html`to `ejs`.

### Layouts

To sovle the problem of repetitive code, appearing in each page, will use the concept of layout file. A layout file contains everything common in a page. In the index.ejs, noticed that the repeating elements:

```js
const ejs= require('ejs');
const app= new express();
app.set('view engine', 'ejs');
```

And finally extract the `script`elements into scripts.ejs like:

```html
<script src="vendor/jquery/jquery.min.js"></script>
```

Having extracted header, nav, footer and scripts into the various layout files, `index.ejs`now include the various layout files in place of extracted code as shown like:

```ejs
<%- include('layout/header'); -%>
<body>
    <%- include('layout/navbar'); -%>
    <!-- ... the body -->
    <hr>
    <%- include('layout/footer'); -%>
</body>
```

MongoDB -- is a NoSQL dbs, before we talk about -- first tall about relational dbs so that can provide a meaningful contrast. MongoDB stores one or more collections, a *collections* represents a single entity in our app, fore, in an e-commerce app, need entities like categories, users, products. A *collection* then contain documents.

### Mongoose

To talk to MongoDB from Node, need a library, Mongoose is an officially supported Node.js package.

`npm install mongoose`-- connecting to MongoDB from Node -- first in the index.js, add the following code like:

```js
const mongoose = require('mongoose');
const Schema = mongoose.Schema;
const BlogPostSchema = new Schema({
    title: String,
    body: String,
});

const BlogPost = mongoose.model('BlogPost', BlogPostSchema);
module.exports = BlogPost;
```

Access the dbs via mongoose.model -- the first argument is the singular name of the collection your model is for. Mongoose automatically looks for the plural version of your model name. Cuz, use `BlogPost`, and Mongoose will create the model for our `BlogPosts`collection.

```js
const mongoose = require('mongoose');
const BlogPost = require('./models/BlogPost');

try {
    // Connect to the MongoDB cluster
    mongoose.connect(
        'mongodb+srv://abc:nLuFwDoLUJbNIuI7@cluster0.hti4s.mongodb.net/',
        { useNewUrlParser: true, useUnifiedTopology: true },
    );
} catch (e) {
    console.log("could not connect");
}

BlogPost.create({
    title: 'The Mythbuster’s Guide to Saving Money on Energy Bills',
    body: `If you have been here a long time, you might remember when I went on ITV Tonight to
    dispense a masterclass in saving money on energy bills. Energy-saving is one of my favourite money
    topics, because once you get past the boring bullet-point lists, a whole new world of thrifty nerdery
    opens up. You know those bullet-point lists. You start spotting them everything at this time of year.
    They go like this:`
}).catch(err=>console.log(err));
```

### Code explanation -- 

import the BlogPost model jsut created by specifying its relative path. `BlogPost`represents the collection in the dbs. Just noticed there is an additional filed `_id`is a unique id provided by MongoDB every document.

## Returning a nil recevier

In this, discuss the *impact of returning an interface* and why doing so may lead to errors in some conditions. This mistake is probably one of the most widespread in go cuz it may be considered counterintutive. Like:

```go
type MultiError struct {
	errs []string
}

func (m *MultiError) Add(err error) {
	m.errs = append(m.errs, err.Error())
}

func (m *MultiError) Error() string {
	return strings.Join(m.errs, ";")
}
```

For this, `MultiError`just satisfies the `error`interface cuz it implements the `Error() string`method. Meanwhile, it exposes an `Add`method to append an error. Using this struct, can implement a `Customer.Validate()`method in the following manner like:

```go
func (c Customer) Validate() error {
	var m *MultiError
	if c.Age < 0 {
		m = &MultiError{}
		m.Add(errors.New("age is negative"))
	}
	if c.Name == "" {
		if m == nil {
			m = &MultiError{}
		}
		m.Add(errors.New("name is nil"))
	}
	return m
}
```

For this, `MultiError`satisfies the `error`interface cuz it implements `Error()`string. For in main:

```go
func main() {
	customer := Customer{33, "John"}
	if err := customer.Validate(); err != nil {
		log.Fatalln("Customer is invalid!")
	}
}
```

In Go, have to know that a pointer receiver can be `nil`-- fore, create a dummy type and calling a method with a nil pointer receiver like:

```go
type Foo struct{}
func(foo *Foo) bar() string {
    return "bar"
}==>
func Bar(foo *Foo) string {
    return "bar"
}
```

For this, if `foo`is initialized to the zero value of a poitner, this code compiles, and it prints `bar`if we run that. For the example, the program like:

```go
func (c Customer) Validate() error {
    var m *MultiError
    if c.Age<0 {}
    if c.Name=="" {}
    return m
}
```

m is just initialized to the zero value of a pointer `nil`-- then if all the checks are valid, the argument provided to the `return`statement isn’t `nil`directly but a `nil`pointer -- cuz a `nil`pointer is a valid receiver, converting the result into an interface won’t yield a `nil`. To make this point clear -- interface is a dispatch wrapper. Therefore, regardless of the `Customer`provided, the caller of this func will always receive a non-nil error. Should:

```go
func (c Customer) Validate() error {
    var m *MultiError
    //...
    if m!= nil {
        return m
    }
    return nil
}
```

## Brief Introduction to Bcrypt

If your dbs is ever compromised by an attacker, it’s hugely important that it doesn’t contain the plain-text versions of your user’s pwds -- Good practice -- essential, really, to store a one-way hash of the passord, derived with a computationally expensively key-dervation function. There are two functions in the bcrypt package use this. like:

```go
hash, err := bcrypt.GenerateFromPassword([]byte("my plain password"), 12)
```

The second pass in here indicates the cost, which is represented by an integer between 4 and 31. the code uses a cost of 12, which means that 4096. 

On the flip side, can check that a plain-text password matches a particular hash using the function like:

```go
hash := []byte("...")
err := brcypt.CompareHashAndPassword(hash, []byte("my plain"))
```

### Storing the User Details

The next stage of our build is to update the `UserModel.Insert()`method so that it creates a new record in our `users`table containing the validated name, email, and hashed password.

This will be interesting for two reasons, first want to store the brcypt hash of the pwd, and second, also need to manage the potential error cauzed by a duplciate email violating the UNIQUE constraint.

```go
type UserModel struct {
    DB *sql.DB
}

func (m *UserModel) Insert(name, email, password string) error {
    hashedPassword, err := brcypt.GenerateFromPassword([]byte(password), 12)
    if err != nil {
        return err
    }
    stmt := `Insert into users... values(?, ?, ?, UTC_TIMESTAMP())`
    _, err := m.DB.Exec(stmt, name, email, string(hashedPassword))
    if err != nil{
        //...
        return err
    }
    return nil
}

// ... 
func (app *application) SignUser(w http.ResponseWriter, r *http.Request) {
    err := r.ParseForm()
    if err!=nil {
        app.clientError(...)
        return
    }
    //...
    err = app.users.Insert(form.Get("name"),...)
    if err != nil {
        //...
    }
    
    // otherwise, add a confirmation flash message -- 
}
```

### User Logout

This brings us nicely to logging out a user. Implementing the user logout is just remove the `authenticatedUserID`from their session. just update the `logoutUser`handler to exactly -- 

```go
func(app *application) logoutUser(w http.ResponseWriter, r *http.Request) {
    app.session.Remove(r, "authenticationUserID")
    app.session.Put(r, "flash", "you have been logged out")
}
```

### User Authorization

Being able to authenticate the users of our app is all well and good, but now we need to do sth useful with that info. In this chapter, introduce some *authorization* checks so that -- 

1. Only authenticated users can create a new snippet and
2. The contents of the navigation bar changes depending on whether a user is authenticated or not. Authenticated users should see links to `home`, create snippet and logout, unauthenticated users should see links, home, signup and login.

We can just check whether a request being made by an authenticated user or not by checking for the existence of an `authenticatedUserID`value in their session data.

For this, add an `isAuthenticated()`helper function to return the authentiation status like so:

```go
func (app *application) isAuthenticated(r *http.Request) bool {
	return app.session.Exists(r, "authenticatedUserID")
}
```

Now can check whether or not the request is coming from an authenticated user by simply calling this helper function.

```go
type templateData struct {
	CurrentYear     int
	Snippet         *models.Snippet
	Snippets        []*models.Snippet
	Flash           string
	Form            *forms.Form
	IsAuthenticated bool
}
```

And the second step is to update our `addDefaultData()`helper so that this info is automatically added the `templateData`struct every we render a template like so:

```go
func (app *application) isAuthenticated(r *http.Request) bool {
	return app.session.Exists(r, "authenticatedUserID")
}

func (app *application) addDefaultData(td *templateData, r *http.Request) *templateData {
	if td == nil {
		td = &templateData{}
	}

	td.CurrentYear = time.Now().Year()
	td.Flash = app.session.PopString(r, "flash")

	// add the authentication status to the template data
	td.IsAuthenticated = app.isAuthenticated(r)
	return td
}

```

Once done, can just update the `ui/html/base.layout.html`file like:

```html
<div>
    <a href="/">Home</a>
    {{if .IsAuthenticated}}
    <a href="/snippet/create">Create snippet</a>
    {{end}}
</div>
<div>
    {{if .IsAuthenticated}}
    <form action="/user/logout" method="post">
        <button>Logout</button>
    </form>
    {{else}}
    <a href="/user/signup">Signup</a>
    <a href="/user/login">Login</a> 
    {{end}}
</div>
```

