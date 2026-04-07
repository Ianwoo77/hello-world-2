# Adding Validation Checks

Move on and create some validation checks  for our `User`struct. Specifically, want to -- 

- Check that the `Name`field is not the empty string, and the value is less than 500 bytes long.
- Check tha the `Email`field is not the empty string, ant that it matches the regular expression for email addresses that we added in our `validator`package earlier in the book.
- If the `Password.plaintext`field is not `nil`-- then back that the value is not the empty string and is between 8 and 72 bytes long.
- Check that the `Password.hash`fields never `nil`.

Additionally, we are going to want use the email and plaintext password validation checks again independently later in the book -- define those checks in some standalone functions.

```go
func ValidateEmail(v *validator.Validator, email string) {
	v.Check(email != "", "email", "must be provided")
	v.Check(validator.Matches(email, validator.EmailRX), "email", "must be a valid email address")
}

func ValidatePasswordPlaintext(v *validator.Validator, plaintext *string) {
	if plaintext != nil {
		v.Check(*plaintext != "", "password", "must be provided")
		v.Check(len(*plaintext) >= 8, "password", "must be at least 8 bytes long")
		v.Check(len(*plaintext) <= 72, "password", "must not be more than 72 bytes long")
	}
}

func ValidateUser(v *validator.Validator, user *User) {
	v.Check(user.Name != "", "name", "must be provided")
	v.Check(len(user.Name) < 500, "name", "must be less than 500 bytes long")

	// call the email and password validators
	ValidateEmail(v, user.Email)
	ValidatePasswordPlaintext(v, user.Password.plaintext)

	v.Check(user.Password.hash != nil, "password", "must be provided")
}
```

#### Creating the `UserModel`

The next step in this process is setting up a `UserModel`type which isolates the dbs interactions with our PostgreSQL `users`table. We will follow the same pattern here that we used for our `MovieModel`, and implement the following 3 methods -- 

- `Insert()`to create a new user record in the dbs
- `GetByEmail()`to retreive the data for a user with a specific email address
- `Update()`-- to change the data for a specific user.

```go
func (m UserModel) Insert(user *User) error {
	query := `
		INSERT INTO users (name, email, password_hash, activated)
		VALUES ($1, $2, $3, $4)
		RETURNING id, created_at, version`

	args := []interface{}{user.Name, user.Email, user.Password.hash, user.Activated}

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, query, args...).Scan(&user.ID, &user.CreatedAt, &user.Version)
	if err != nil {
		switch {
		case err.Error() == `pq: duplicate key value violates unique constraint "users_email_key"` ||
			err.Error() == `pq: duplicate key value violates unique constraint "users_email_idx"`:
			return ErrDuplicateEmail
		default:
			return err
		}
	}
	return nil
}

// Update the details for a specific user, notice that we check against the version
// field to help prevent any race conditions during the request cycle, just like we did
// when updating a movie, and we also chekc for a vlidation of the `users_email_key`
// constraint when performing the udpate.
func (m UserModel) GetByEmail(email string) (*User, error) {
	query := `
		SELECT id, created_at, name, email, password_hash, activated, version
		FROM users
		WHERE email = $1`

	var user User

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, query, email).Scan(
		&user.ID,
		&user.CreatedAt,
		&user.Name,
		&user.Email,
		&user.Password.hash,
		&user.Activated,
		&user.Version,
	)

	if err != nil {
		switch {
		case errors.Is(err, sql.ErrNoRows):
			return nil, ErrRecordNotFound
		default:
			return nil, err
		}
	}

	return &user, nil
}
```

Hopefully that feels nice and straightforward -- we are using the same code patterns that we did for the CRUD operations on our `movies`table earlier in the book. The only difference is that in some of the methods we are specifically checking for any errors due to a violation of our unique `users_email_key`constraint. Rather than sending them a *500 internal Server Error* response like we normally would.

To finish all this off, the final thing we need to do is update our `internal/data/models.go`file to include the new `UserModel`in our parent `Models`struct -- 

```go
type Model struct {
    Movies MovieModel
    Users UserModel
}

type NewModels(db *sql.DB) Models {
    return Models {
        Movies: MovieModel {DB:db}
        Users: UserModel{DB: db}
    }
}
```

#### Registering a user

Now that laid groundwork -- let's start putting it to use by creating a new API endpoint to manage the process of registering a new user -- `POST /v1/users`-- `registerUserHandler`-- 

```json
{
    "name": "Alice Smith",
	"email": "alice@example.com",
	"password": "pa55word"
}
```

In fact, we've already written most of the code we need for the `registerUserHandler`-- it's now just a case of piecing it all together in the correct coder.

```go
func (app *application) registerUserHandler(w http.ResponseWriter, r *http.Request) {
	var input struct {
		Name     string `json:"name"`
		Email    string `json:"email"`
		Password string `json:"password"`
	}

	err := app.readJSON(w, r, &input)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	user := &data.User{
		Name:      input.Name,
		Email:     input.Email,
		Activated: false,
	}

	// Set the password hash
	err = user.Password.Set(input.Password)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	v := validator.New()

	if data.ValidateUser(v, user); !v.Valid() {
		app.failedValidationResponse(w, r, v.Errors)
		return
	}
    
    // insert the user data into the database
    err = app.models.Users.Insert(user)
    if err != nil {
        switch {
        case errors.Is(err, data.ErrDuplicateEmail):
            v.AddError("email", "a user with this email addres already exists")
            app.failedValidationResponse(w, r, v.Errors)
        default:
            app.ServerErrorRepsonse(w, r, err)
        }
        return
    }
    
    // Write a JSON resonse containing the user data along with a 201
    err = app.writeJON(w, http.StatusCreated, envelope{"user", user}, nil)
    if err != nil {
        app.serverErrorResponse(w, r, err)
    }
}
```

```sh
BODY='{"name": "Alice Smith", "email": "alice@example.com", "password": "pa55word"}'
curl -i -d "$BODY" localhost:4000/v1/users
```

That's looking good, when can from the status code that the user record has been successuflly created, and in the JSON response we can see the system-generated information for the new user -- including user's `ID`and activation status -- take a look your PostgreSQL dbs.

```sh
BODY='{"name": "", "email": "bob@invalid.", "password": "pass"}'
curl -d "$BODY" localhost:4000/v1/users
```

#### Additional Information

Talk quickly about mail addresses case-sensitivety a bit more detail.

- Thanks to the specifications in RFC 2821 -- the domain part of an email address `username@domain`in Case-insenstive -- this means we can be confident tht the real-life user beind `alice@example.com`is the same pattern as `alice@EXAMPLE.COM`
- The username part of an email address *may* or *may* not be case-sensitive -- it depends on the email provider. Almost every major email provider treats the username as case-insensitive.

From a security point of view, should always store the email address using the exact casing provided by the user during registration, we should send them emails using that exact casing only.

##### User enumeration

It's important to be aware that our registion endpoint is vulnerable to *user enumation* -- 

```sh
BODY='{"name": "Alice Jones", "email": "alice@example.com", "password": "pa55word"}'
curl -d "$BODY" localhost:4000/v1/users
```

##### Sending Emails -- 

In this section of the book we are going to inject some interactivity into our API - and adapt our `registerUserHandler`so that it sends the user a welcome email after the successfully register. In the process of doing this we are going to cover a few interesting topics -- 

- How to use the `Mailtrap`SMTP service to send and monitor test emails during development.
- How to use the `html/template`package and Go's *embedded files* functionality to create dynamic and easy-to-manage templates for your email content.
- How to create a reusable `internal/mailer`package for sending emails from your application
- How to implement a pattern for sending emails in background goroutines, and how to wait for these to complete during a graceful shudown.

#### SMTP Server Setup

In order to develop our email sending functionality, need access to a SMTP server we can safely use for testing purposes -- There are a huge number of SMTP service providers that could use to send our emails. The reason for using Mailtrap is cuz it's specialist service for *sending emails during* development and tesing. Essentially it delivers all emails to an inbox that can access, instead of sending them to the actual recipient.

I've got no affliation with the company - Just find that the service works well and is simple to use. They also offer a free forever's plan.

##### Setting up Mailtrap

To setup a Mailtrap account, head to the *signup page* where U can register using either your email address or your Google or Github accounts.

To Start with, we will keep the content of the welcome email really simple, with a short message to let the user know that their registrtion was successful and confirmation of their ID number. There are several different apporaches we could take to define and manage the content for this email - but a convenient and flexible way is to use Go's templating functionliaty from the `html/template`package. Then you are following along, begin by creating a new `internal/mailer/templates`folder in your project directory and then add `user_welcome.tmpl`file.

- A `subject`template containing the subject line for the email.
- A `plainBody`template containing the plain-text variant of the email message body
- A `htmlBody`template containing the HTML variant of the email message body.

```html
{{define "subject"}}Welcome to Greenlight!{{end}}

{{define "plainBody"}}
    Hi,
    Thanks for signing up for a Greenlight account. We're excited to have you on board!
    For future reference, your user ID number is {{.userID}}.
    Please send a request to the `PUT /v1/users/activated` endpoint with the following JSON
    body to activate your account:
    {"token": "{{.activationToken}}"}
    Please note that this is a one-time use token and it will expire in 3 days.
    Thanks,
    The Greenlight Team
{{end}}

{{define "htmlBody"}}
<!doctype html>
<html>
<head>
    <meta name="viewport" content="width=device-width" />
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
</head>
<body>
    <p>Hi,</p>
    <p>Thanks for signing up for a Greenlight account. We're excited to have you on board!</p>
    <p>For future reference, your user ID number is {{.userID}}.</p>
    <p>Please send a request to the <code>PUT /v1/users/activated</code> endpoint with the
    following JSON body to activate your account:</p>
    <pre><code>
    {"token": "{{.activationToken}}"}
    </code></pre>
    <p>Please note that this is a one-time use token and it will expire in 3 days.</p>
    <p>Thanks,</p>
    <p>The Greenlight Team</p>
</body>
</html>
{{end}}
```

This template syntax and structure should look very familar to U and we won't dwell on the details again here. 

- We've defined 3 named templates using the `{{define "..."}} ... {{end}}`tags.
- Can render dynamic data these templates via the `.`character -- in the next chapter we will pass a `User`struct to the templates as dynamic data, which means that we can then render the user' ID using the tag `{{.ID}}`in the templates.

#### Sending a Welcome Email

To send emails could use Go's `net/smtp`package from standard library. But unfortunately it's been frozen for a few years, and doesn't support some of the features that you might need in more advanced use-cases, such as the ability to add attachments. So instead, I recommand using the 3rd-party `go-email/mail`package to help send email.

```sh
go get github.com/go-mail/mail/v2@v2
```

##### Creating an email helper

Rather than writing all the code for sending the welcome email in our `registerUserHandler`, in this chapter we are going to create a new `internal/mailer`package which wraps up the logic for parsing our email templates and sending emails.

```go
// declare a new variable with the type of `embed.FS` to hold our email templates
// format is `//go:embed <path>` immediately above the variable declaration
// IMMEDIATELY ABOVE it - which indicates the Go that we want to store the contents.

//go:embed "templates"
var templateFS embed.FS

// Mailer Define a Mailer struct which contains a mail.Dialer instance and the sender information
// for your emails fore:
type Mailer struct {
	dialer *mail.Dialer // github.com/go-mail/mail/v2
	sender string
}

func New(host string, port int, username, password, sender string) Mailer {
    // Initialize a new mail.Dailer instance with the given SMTP server settings
    // we also configure this to use a 5-s timeout whenever we send an email
    dialer := mail.NewDialer(host, port, username, password)
    dialer.Timeout = 5 * time.Second
    
    return Mailer (
        dialer: dialer,
        sender: sender,
    )
}
```

- When use the directive `//go:embed "<path>"`-- to create an embedded file system, the path should be *relative* to the source code file containing the directive. In our case, `//go:bed "template"`embeds the contents of the directory at `internal/mailer/templates`.
- The embedded file system is rooted in the directory which contains the `//go:embed`directive. So our case, to get the `user_welcome.html`file need to retreive it from `templates/user_welcome.html`in the embedded file system.
- Paths cannot contain `.`or `..`elements, nor may they begin or end with a `/`-- this essentially restricts U to only embedded files that are contained in the same directory as the source code which has the `//go:embed`directive
- If the path if for a directory, then all files in the directory are recursively embedded. Want to implement like `//go:embed "template/*"`
- Can specify multiple directories and files in one directive.

##### Using our mail helper - 

- Adapt code to accept the configuration settings for the SMTP server as command-line flags
- Initialize a new `Mailer`instance and make it available to our handlers via the `application`struct.

## Building Forms

For a lost of us, being a web developer means collecting large amounts of information from users with forms. If this sounds like your job, then you will be buidling a lot of form components. All of the HTML form elements that are available to the DOM are also available as React elements.

```tsx
<from>
	<input type="text" placeholder="color title..." required />
    <input type="color" required />
    <button>ADD</button>
</from>
```

This `form`element has 3 child elements -- two `input`elements and a `button`-- the first `input`element is a text input that will be used to collect the `title`value for new colors.

#### Using `Refs`

When it's time to build a form component in React, there are several patterns available to U. One of these patterns involves accessing the DOM node directly using a React feature called refs.

```tsx
import React, {useRef} from "react";

export default function AddColorForm({onNewColor=f=>f}) {
    const txtTitle = useRef();
    const hexColor = useRef();
    const submit = e=> {
        e.preventDefault();
        const title= txtTitle.current.value;
        const color = hexColor.current.value;
        onNewColor(title, color);
        txtTitle.current.value = "";
        hexColor.current.value = "";
    }
    return (
        <form onSubmit={submit}>
            <input ref={txtTitle} type="text" placeholder="color title..." required/>
            <input ref={hexColor} type="text" placeholder="#FFFFFF" required/>
            <button>ADD</button>
        </form>
    )
}
```

When we submit HTML forms, by default, they send a POST request to the current URL with the values of the form elements stored in the body. Don't want to do that -- This is why first line of code in the `submit`function is `e.preventDefault()`-- which prevents the browser from trying to submit the form with a POST request.

Next, we capture the current values for each of our form elements using their refs -- these values are then passed up to this component's parent via the `OnNewColor`function property. Both the title and the hexadecimal value for new color are passed as function arguments. Finally, we reset the `value`attribute for both inputs to clear the data and prepare the form to collect another color.

##### Controlled Components

In a *controlled component* -- the form values are managed by React and not the DOM. The do not require us to write imperative code. Adding features like rubust form valiation is much easier when working with a controlled component. Modify the `AddColorForm`by giving it control over the form's state.

```tsx
export default function AddColorForm({onNewColor=f=>f}) {
    const [titleProps, resetTitle]= useState("");
    const [colorProps, resetColor]= useState("#000000");
    
    const submit = e=> {
        e.preventDefault();
        onNewColor(titleProps.value, colorProps.value);
        resetTitle();
        resetColor();
    }
    return (
        <form onSubmit={submit}>
            <input
                {...titleProps}
                type="text" placeholder="color title..." required/>
            <input {...colorProps} type="color" required/>
            <button type="submit">Add</button>
        </form>
    )
}

function App() {
    const [colors, setColors] = useState(colorData);
    return (
        <>
            <AddColorForm
                onNewColor={(title,color)=> {
                    const newColors=[
                        ...colors,
                        {
                            id: v4(),
                            rating:0,
                            title,
                            color
                        }
                    ];
                    setColors(newColors);
                }}
                />
            <ColorList />
        </>
    );
}
```

### React Context

Storing state in one location at the root of our tree was an important pattern that helped us all be more successful with early versions of React. Howeer, As React evolved and our component trees got larger, following this principle slowly became more unrealistic.

The UI elements that most of us work on are complex -- The root of the tree is often very far from the leaves -- this puts data the application depends on many layers always from the components that use the data. In React, *context* is like jet-setting for your data. Can place data in React context by creating a context provider.

##### Placing Colors in Context

In order to use context in React, we must first place some data in a context provider and add that provider to our component tree.

```tsx
function App() {
    return(
        <>
            <addColorForm/>
            <ColorList />
        </>
    )
}
```

##### Retrieving Colors with `useContext`

The addition of hooks makes working with context joy -- The `useConetxt`hook is used to obtain values from context, and it obtains those values we need from the context `Consumer`. The `ColorList`component no longer needs to obtain the array of `colors`from its properties.

The addition of hooks makes working with context a joy -- the `useContext`hook is used to obtain values from context, and it obtain those values we need from the context `Consumer`-- the `ColorList`component to longer needs to obtain the array of `colors`from its properties -- can access them directly via the `useContext`hook -- 

```jsx
export default function ColorList() {
    const {colors}= useContext(ColorContext);
    if(!colors.length) return <div>No colors listed.</div>;
    return(
    	<div classnName="color-list">
        	{colors.map(color=><Color key={color.id} {...color} />)}
        </div>
    );
}
```

##### Stateful Context Providers

The context provides can place an object into context, but it can't mutate the values in context on its own. It needs some help from a parent component. The trick is to create a stateful component that renders a context provider. The stateful component that renders the context provider is our *Custom provider* -- 

```jsx
const ColorContext = createContext();

export default function ColorProvider({children}) {
    const [colors, setColors]= useState(colorData);
    return(
    	<ColorContext.Provider value={{colors, setColors}}>
        	{chidren}
        </ColorContext.Provider>
    )
}
```

### Fetching data using an RSC

In this section, will implement data fetching the blog post list and blog details RSCs to get the data from our new database -- will structure the code that interacts with the dbs in separate functions -- Call them query functions.

1. Create a file called `.env`in the project root with the following content -- 

   `DB_URL=file:src/data/blog.db`

2. Create a file called `queries.ts`in the `src/data`folder, add the following content to `queries.ts`to import a function from libSQL that allow us to connect the dbs.

3. Create type for the post data as follows - 

   Adding type safety to database query -- `npm i zod`

   ```js
   import {z} from `zod`;
   
   type Post = {
       id: number;
       title: string;
       description: string;
   };
   
   export async function getAllPosts() {
       const client = createClient({
           url: process.env.DB_URL ?? '',
       });
       const data = await client.execute(
           `SELECT CAST(id as text) as id, title, description
            FROM posts`);
       client.close();
       return postsSchema.parse(data.rows);
   }
   
   export async function getFilteredPosts(criteria: string) {
       const client = createClient({
           url: process.env.DB_URL ?? '',
       });
       const data = await client.execute({
           sql: `Select id, title, description
                 FROM posts
                 WHERE title LIKE ?`,
           args: ['%${criteria}%'],
       });
   
       client.close();
       return postsSchema.parse(data.rows);
   }
   
   export async function getPost(id: number) {
       const client = createClient({
           url: process.env.DB_URL ?? '',
       });
       const data = await client.execute({
           sql: `Select id, title, description
                 FROM posts
                 WHERE id = ?`,
           args: [id],
       });
       client.close();
       if (data.rows.length === 0) {
           return undefined;
       }
       return postsSchema.parse(data.rows)[0];
   }
   
   export const postSchema = z.object({
       id: z.number(),
       title: z.string(),
       description: z.string(),
   });
   
   export const postsSchema = z.array(postSchema);
   ```

#### Adding loading indicators using React Suspense

In this section, will learn about *React Suspense* -- and use it to implement a loading indicator in the RSCs that fetch data in our app -- this will improve the loading user experience.

##### Understanding the need for loading indicators

Currently, the data-fetching user experience in our app is reasonable cuz the process is quick. This is cuz everything is running locally, and so the latency is low -- this is also cuz the dbs is small, and the queries are simple, so they execute fast -- we are the only user using the app.

##### Adding a delay

```jsx
async function delay() {
    await new Promise((resolve)=>
        setTimeout(resolve, 1000),);
}

export async function getAllPosts() {
    await delay();
    // ...
}
```

Will eventually improve the experience so that the page immediately loads with a loading indicator informing the user that some content is till loading.

#### Understanding React Suspense

React Suspense enable components to wait for async tasks during rendering -- A common async task that `Suspense`is used for is *data fetching*. It allows the rendering of some JSX elements to be *suspend* while data being fetched, allowing other elements to be rendered normally.

The `Supspense`fallback can be shown to the user before suspended elements cuz RSCs containing suspended elements are streamed to the browser. So the Suspense fallback will be sent to the browser in the first chunk.

##### Implementing Loading indicators

Will use React Suspense to add loading indicators to parts of the page components for the blog post list and details. We will extract async parts the components into child components so that they can be wrapped with a `Suspense`.

```tsx
export function Loading() {
    return(
        <div className="skeleton">
            <div className="skeleton-item-title"></div>
            <div className="skeleton-item-desc"></div>
        </div>
    )
}
```

The component renders `div`elements that visually represents placeholders for the blog post title and description.

```tsx
export async function PostList({criteria,}:
                               { criteria: string | string[] | undefined; }) {
    const resolvedPosts = typeof criteria === 'string'
        ? await getFilteredPosts(criteria)
        : await getAllPosts();

    return(
        <ul>
            {resolvedPosts.map((post) => (
                <li key={post.id}>
                    <Link href={`/posts/${post.id}`}>
                        {post.title}
                    </Link>
                    <p>{post.description}</p>
                </li>
            ))}
        </ul>
    )
}
```

Replace the `ul`and `li`elements in the JSX with `PostList`inside a `Suspend`component -- 

```tsx
return (
    <main>
        <h2>{resolvedHeading}</h2>
        <Suspense fallback={<Loading />}>
            <PostList criteria={criteria} />
        </Suspense>
    </main>
);
```

Open the `src/app/posts/[id]/page.tsx`-- will extract the data fetching and rendering from `Post`into `PostDetail`component.

```tsx
export async function PostDetails({id,}: {id:number;}) {
    const post = await getPost(id);
    if(!post)
        return <p>Post not found</p>;
    return(
        <>
            <h2>{post.title}</h2>
            <p>{post.description}</p>
        </>
    );
}
```

Inside the `Post`component -- remove the `post`variable and guard clause for the blog post not being found, Keep the `id`varaible in place.