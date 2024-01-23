# Github getting started

```sh
git remote add origin https://github.com/Ianwoo77/test.git
```

`git remote add origin URL`just specifies that you are adding a remote repository, with the specified URL, as an origin to your local Git repo. Now that we going to push our master branch to the origin url, set it as the default remote branch under this directory. Using ssh mode needed:

```sh
git remote add origin git@github.com:Ianwoo77/test.git
git config credential.helper store
git push --set-upstream origin master
```

### Github pull 

When working as a tem on a proj, it is just important thate everyone stays up to date. pull is combination of 2 different commands -- `fetch`and merge -- `fetch`gets ll the changes history of a tracked branc/repo

```sh
git fetch origin
# now that have the recent changesm, can check our status like:
git status
git log origin/master
git diff origin/master
git merge origin/master # combines the current branch, with a specified branch
```

So -- what if just want to update your local repository, without going through all those steps -- *`pull`is a combination of `fetch`and `merge`*-- it is just used to pull all changes from a remote repository into the branch you are working on.

```sh
git pull origin
```

now that have recent changes, can check our status again like:

```sh
git status
```

That is how you keep your git up to date from a remote repository.

## App walkthrough -- Node.js source code

```dockerfile
FROM diamol/node AS builder
WORKDIR /src

COPY src/node_modules/*.* .

#app
FROM diamol/node
EXPOSE 80
CMD ["node", "server.js"]

WORKDIR /app
COPY --from=builder /src/node_modules /app/node_modulses/
COPY src/ .
```

The goal here is the same as for the Java app -- to package and run the app with only Docker installed, without having to install any other tools. The base image for both stage is `diamol/node`, which has the Node.js runtime and npm installed. The builder stage in the Dockerfile copies the packages.json files.

```sh
docker image build -t access-log .
```

So the Node.js app built then run:

```sh
docker container run --name accesslog -d -p 801:80 --network nat access-log
```

### App walkthrough -- Go source code -- 

Means that can compile your apps to run on any platform -- and compiled output is the complete application. Don’t need a spearate runtime -- and that makes for extremely small Docker image. Go has the widest plat support, and it’s also a very popular language for cloud-native apps. Building Go apps in the Docker means using a multi-stage Dockerfile approach similar to the one used for the java -- but just like:

```dockerfile
FROM diamol/golang AS builder

COPY main.go .
RUN go build -o /server

# APP
FROM diamol/base

ENV IMAGE_API_URL="http://iotd/image" \
    ACCESS_API_URL="http://accesslog/access-log"
CMD ["/web/server"]

WORKDIR web
COPY index.html .
COPY --from=builder /server .
RUN chmod +x server
```

Go compiles to native binaries, so each stage in the Dockerfile uses a different base images. The application stage ends by copying in the HTML file the application serves from the host and the web server binary from the builder stage.

```sh
docker image build -t image-gallery .
```

Can take a look at the size of the images that go in and come out like:

```sh
docker image ls -f reference=diamol/golang -f reference=image-gallery
```

## user Authentication

In this section of the book we are going to add some user authentication functionality to our app, so that only registered, logged-user can create new snippets. For non-logged-in users will still be able to view the snippets. The process will work like this -- 

1. A user will register by visiting a form at /user/signup and entering name..
2. A user will log by visiting a form at `/user/login`and entering their email address and pwd.
3. Then check the dbs to see if the eamil and password they entered match one of the users in the `users`table.
4. When receive any subsequent requests, can check the user’s session data for the `authenticationUserID`value. If exists, know the user has already successfully logged in.

How to implement basic `signup, login logout`functionality for users, A secure approach to encrypting and storing user pwds securely in your dbs using `Bcrypt`. A solid and straightforward approach to verifying that user is logged in using middleware and sessions, how to prevent Cross-site request forgery attacks.

- `GET /user/signup`,  display signup form
- `GET /user/login`-- display the user login form
- `POST /user/login` -- authenticate and login the user

```go
dynamicMiddleware := alice.new(app.session.Enable)
// Add the five new routes
mux := pat.New()
mux.Get("/user/signup", dyanmicMiddle.ThenFunc(app.signupUser))
//...
```

### Creating a Users Model

Now that routes are set up, need to create a new `users`dbs table and a dbs model to access it. first:

```sql
user snippetbox;

CREATE table users (
	id INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
    name...
    email...
    hased_password CHAR(60) NOT NULL,
    created DATETIME NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE
);

ALTER TABLE users add CONSTRAINT users_uc_email UNIQUE(email);
```

### Building the Model in Go

Setup a model so that we can easily work with the new `users`table. follow the same pattern that we used earlier in the book for modeling access to the snippets table.

```go
var (
    ErrNoRecord = errors.New("models: no matching record found")
    //...
)
//...
// define a new user type like:
type User struct {
    ID int
    Name, Email string
    HashedPassoword []byte
    Created time.TIme
    Active bool
}
```

Now that the types have been set up, need to make the actual dbs model just create a new file: `users.go`file: like:

```go
type UserModel struct {
    DB *sql.DB
}

func (m *UserModel) Insert(name, email, password string) error {
    //...
}

app := &application {
    errorLog: ...
    users: &mysql.UserModel{DB:db},
}
```

### User signup and Password Encryption

Before can log in any users to our `Snippetox`we first need a way for them to sign up for an account. Like:

```html
{{with .Form}}
<div>
    <label>Name</label>
    {{with .Errors.Get "name"}}
    <label class="error">{{.}}</label>
    {{end}}
    <input type="text" name="name" value="{{.Get "name"}}">
</div>
```

```go
func (app *application) signupUserForm(w http.ResponseWriter, r *http.Request) {
    app.render(w, r, "signup.page.html", &templateData {
        Form: forms.New(nil),
    })
}
```

#### Validating the User Input

When this form is submitted that data will end up being posted to the `signupUser`handler that made earlier -- The first task of this handler will be to validte the data and make sure that it is sane and sensible before insert it into the dbs. Just do 4 things -- 

1. Check that the user’s name, email address and password are not blank
2. Sanity check 
3. Ensure that the pwd
4. Make sure that the email address isn’t already in use.

```go
var EmailRx = regexp.MustCompile("...")
type Form stuct {
    urls.Values  // for the formcontrol
    Errors errors
}

func (f *form) MinLength(filed string, d int) {
    value := f.Get(field)
    if value == "" {
        return
    }
    if utf8.RuneCountInString(value)<d {
        f.Errors.Add(field, fmt.Sprintf(..., d))
    }
}
```

In the `handler.go`file and add some code to process the form and run the validation checks like so:

```go
func (app *application) signupUser(w http.ResponseWriter, r *http.Request) {
    err := r.ParseForm()
    if err != nil {
        app.clientError(w, http.StatusBadRequest)
        return
    }
    
    form := forms.New(r.PostForm) // validate
    form.Required("name", "email", "password")
}
```

### Brief introcuction to Brcypt 

And if the dbs is ever compromised by y an attacker, it’s hugely important that it doesn’t contain the *plain-text* versions of your user’s pwds -- It’s good practice -- to store a **one-way** hash of the pwd, derived with a computationally expensive key-deviation function.

There are two functions in the `brcypt`package that will use in this book. The first is the `brcypt.GenerateFromPassword()`lets us create a hash of a given plain-text pwd like so: just like:

```go
hash, err := brcypt.GenerateFromPassword([]byte("pwd"), 12)
```

12 passed in here indicates the cost -- wiich is represented by an integer between 4 and 31. The code uses a cost of 12, which means that 4096 brcypt iterations will be used to hash the pwd.

It’s worth pointing out that the `bcrypt.GenerateFromPassword()`also adds a random salt to the pwd. On the flip side, can check that a plain-text pwd matches a particular hash using the `brcypt.CompareHashAndPassword()`func like so:

```go
hash := []byte ("...")
err := bcrypt.CompareHashAndPassword(hash, []byte("..."))
```

The `brcypt.CompareHashAndPassword()`function will return nil if matches or an error otherwise.

#### Storing the user Details

The next stage of our build is to update the `UserModel.Insert()`method so that it just creates a new record in the `users`tble containing the validated name, email, and hashed pwd. This will be interesting for two, first, we want to store the bcrypt hash of the pwd and 2nd, also need to manage the poential error caused by a duplicate email -- violating the `UNIQUE`constraint that added to the table.

Just note for this, all errors returned by MySQL have a particualr code, which can use to triage what has caused the error. In the case of a duplicate email. Just like:

```go
//...
func (m *UserModel) Insert(name, email, password string) error {
    // create a bcrypt hash of plain-text pwd
    hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), 12)
    if err != nil {
        return err
    }
    
    stmt := `INSERT INTO users (name, email, hashed_password, created)
        values(?,?,?,UTC_TIMESTAMP())`
    
    // then use the Exec() method to insert the user details and hashed password
    _, err = m.DB.Exec(stmt, name, email, string(hashedPassword))
    if err != nil {
        var mySQLError *mysql.MySqlError
        if errors.As(err, &mySqlError) {
            if mySqlError.Number == 1062 && strings.contains(mySQLError.Message, 
                                                             "users_uc_email") {
                return models.ErrDuplicateEmail
            }
        }
        return err
    }
    return nil
}
```

Can then finish this all off by updating the `signupUser`handler like -- 

```go
//... try to create a new user record in the dbs like:
err = app.users.Insert(form.Get("name"), form.Get("email"), form.Get("password"))
if err != nil {
    if errors.Is(err, models.ErrDuplicateEmail) {
        form.Errors.Add("email", "address is already in use")
        app.render(w, r, "signup.page.html", &templateData{form})
    }else{
        app.serverError(w, err)
    }
    return
}

// otherwise, just add a confirmation flash message just like:
app.session.Put(r, "flash", "your signup was successful, please log in.")
// add redirect the user to the login page
http.Redirect(w, r, "/user/login", http.StatusSeeOther)
```

For this -- some databases provide built-in functions that you can use for pwd hashing and verification instead of implementing your own in Go.

Alternatives for checking Email Duplicates -- Unserstand that the code in our `UserModel.Insert()`method isn’t very pretty, and that checking the error returned by MySQL feels a bit flaky.

### User Login

The process for creating the user login page follows the same general pattern as the user signup.

```html
{{template "base" .}}

{{define "title"}} Login {{end}}

{{define "main"}}
    <form action="user/login" method="post" novalidate>
        {{with .Form}}
            {{with .Errors.Get "generic"}}
                <div class="error">{{.}}</div>
            {{end}}

            <div>
                <label>Email:</label>
                <input type="email" name="email" value="{{.Get "email"}}">
            </div>
            <div>
                <label>Password:</label>
                <input type="password" name="password">
            </div>

            <div>
                <input type="submit" value="Login">
            </div>

        {{end}}
    </form>
{{end}}
```

Notice that includes a `{{with .Error.Get "generic"}}`action at the top of the form, instead of displaying of error messages for the individual fields -- use this to present the user with a generic .

```go
func (app *application) loginUserForm(w http.ResponseWriter, r *http.Request) {
	app.render(w, r, "login.page.html", &templateData{
		Form: forms.New(nil),
	})
}
```

#### Verifying the user details -- 

The next step is the interesting part -- how do we verify that the eamil and password submitted by a user are correct -- The core part of this verification logic will take place in the `UserModel.Authenticate()`method of our user model.

1. First it should retrieve the hashed password assocaited with the email address from our MySQL users table. If the email doesn’t exist in the dbs, or it’s for a user that has been deactivated, will return `ErrInvalidCrentials`
2. Otherwise, want to compare hashed password from the users table with the plain-text password that the user provided when logging in. If they just don’t match, we want to return an `ErrInvalidCrentials`again -- but if they do match, we want to return the user’s `id`value from the dbs.

```go
// Authenticate verifies whether a user exists with the provided email address
// and password, will return the relevant user id
func (m *UserModel) Authenticate(email, password string) (int, error) {
	// retrieve the id and hashed pwd associated with the given value
	var id int
	var hashedPassword []byte
	stmt := "SELECT id, hashed_password from users where email=? and active=true"
	row := m.DB.QueryRow(stmt, email)
	err := row.Scan(&id, &hashedPassword)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return 0, models.ErrInvalidCredentials
		} else {
			return 0, nil
		}
	}

	// check whether the hashed pwd and plain-text pwd provided match
	// if does't just return the `ErrInvalidCretential` error like:
	err = bcrypt.CompareHashAndPassword(hashedPassword, []byte(password))
	if err != nil {
		if errors.Is(err, bcrypt.ErrMismatchedHashAndPassword) {
			return 0, models.ErrInvalidCredentials
		} else {
			return 0, err
		}
	}
	return id, nil
}
```

Next step involves updating the `loginUser`handler so that it parses the submitted login form data.

```go
func (app *application) loginUser(w http.ResponseWriter, r *http.Request) {
	err := r.ParseForm()
	if err != nil {
		app.clientError(w, http.StatusBadRequest)
		return
	}

	// check the credentials
	form := forms.New(r.PostForm)
	id, err := app.users.Authenticate(form.Get("email"), form.Get("password"))
	if err != nil {
		if errors.Is(err, models.ErrInvalidCredentials) {
			form.Errors.Add("generic", "email or password is incorrect")
			app.render(w, r, "login.page.html", &templateData{
				Form: form,
			})
		} else {
			app.serverError(w, err)
		}
		return
	}

	// add the id to the session, show logged in
	app.session.Put(r, "authenticationUserId", id)
	// redirect to create page
	http.Redirect(w, r, "/snippet/create", http.StatusSeeOther)
}
```

Covered quite a lot of ground in the last two chapters -- quickly take stock of where things are get -- 

- Users can now register with the site using the `/user/signup`form, we store the details of registered users in the users table of our dbs.
- registered users can then authenticate using the `/user/login`form to provide their email address and pwd.

User log out -- this brings us to logging out a user just implementing the user logout is just remove the `authenticateUserId`value from session like:

```go
func (app *application) logoutUser(w http.ResponseWriter, r *http.Request) {
	app.session.Remove(r, "authenticationUserId")
	app.session.Put(r, "flash", "you are logged out successfully")
	http.Redirect(w, r, "/", http.StatusSeeOther)
}
```

