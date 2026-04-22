# Sending Activation Tokens -- (2)

The next step is to hook this up to our `registerUserHandler`, so that we generate an activation token when a user signs and include it in their welcome email -- The most important thing about this email is that we are instructing the user to activate by issuling a `PUT`request to our API -- not by *clicking* a link which contiains the token as part of the URL path or query string.

Having a user click a link to activate via a `GET`request would certainly be more convenient, but in the case of our API it has some big drawbacks -- in particular -- 

- It would violate the HTTP principle the `GET`method should only be used for *safe* rquests which retrieve resources -- not for requests that modify something -- 
- It's possible that the user's web browser or antivirus will pre-fetch link URL in the background, inadvertently activating the account. The Stack Overflow comment explains the risk of the nicely.

All-in-all, you should make sure that any actions which change the state of your applicaiton are only ever via `POST, PUT, PATCH`or `DELETE`requests -- not by the `GET`requests.

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

Need to update the `registerUserHandler`to generate a new activation token, and pass it to the welcome email template as dynamic data, along with the user ID.

```go
func(app *application) registerUserHandler(w http.ResponseWriter, r *http.Request) {
    //...
    err = app.models.Insert(user)
    if err != nil {
        switch {
        case errors.Is(err, data.ErrDuplicateEmail):
            v.AddError("email", "a user with email: address already exists")
            app.failedValidationResponse(w, r, v.Errors)
        default:
            app.serverErrorResponse(w, r, err)
        }
        return
    }
    
    token, err := app.models.Tokens.New(user.ID, 3*24*time.Hour, data.ScopeActivation)
    if err != nil {
        app.serverErrorResponse(w, r, err)
        return
    }
    // Launch a goroutine which runs an anonymous function that sends the welcome email.
	app.background(func() {
		// as there are now multiple pieces of data that we want to pass to our email
		// templates, create a map as a holding structure for the data.
		data := map[string]any{
			"activationToken": token.Plaintext,
			"userID":          user.ID,
		}
		err := app.mailer.Send(user.Email, "user_welcome.html", data)
		if err != nil {
			// log the error
			app.logger.Error(err.Error())
		}
	})
    err = app.writeJSON(w, http.StatusAccepted, envelope{"user", user}, nil)
    if err != nil {
        app.serverErrorResponse(w, r, err)
    }
}
```

```sh
BODY='{"name": "Faith Smith", "email": "faith@example.com", "password": "pa55word"}'
curl -d "$BODY" localhost:4000/v1/users
```

### Activating a User

In this chapter, going to move on the part of the activation workflow where we actually activate a user. But before we write any code. I'd like to quickly talk about the relationaship between users and tokens in our system. What we have is known in relational database terms as a one-to-many *relationshp* -- where one user may have many tokens, but a token can only belong to one user.

When U have a one-to-many relationship like this, you will potentially want to execute queries aginst the relationship from two different sides.

- Retrieve the user accociated with a token.
- Retrieve the tokens associated with a user.

##### Creaing the `activateUserHandler`

Now that got a very high-level idea of how we are going to query the token <-> token relationshp in our database models, start to build up the code for activating a user.

`PUT /v1/users/activated`-- `activateUseHandler`-- `Activate a specific user`.

1. The user submits the plaintext activation token to th `PUT /v1/users/activated`endpoint.
2. Validate the plaintext token to check that it matches the expected format, sending the client an error message if necessary.
3. Then call the `UserModel.GetForToken()`method to retrieve the details of the user accociated with the provided token. If there is no matching token found, or it has expired, we send the client an error message.
4. We activate the associated user by setting `activated=true`on the user record and update it in our database.
5. Delete all activation tokens for the user from the tokens table. Can do this using the `TokenModel.DeleteAllForUser()`method that we made eariler.
6. We send the updated use details in a JSON response.

```go
func (app *application) activateUserHandler(w http.ResponseWriter, r *http.Request) {
	var input struct {
		TokenPlaintext string `json:"token"`
	}

	err := app.readJSON(w, r, &input)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	v := validator.New()
	data.ValidateTokenPlaintext(v, input.TokenPlaintext)
	if !v.Valid() {
		app.failedValidationResponse(w, r, v.Errors)
		return
	}

	// Retrieve the details of the user 
    // associated with the token using the GetByToken() method.
	user, err := app.models.Users.GetForToken(data.ScopeActivation, input.TokenPlaintext)
	if err != nil {
		switch {
		case errors.Is(err, data.ErrRecordNotFound):
			v.AddError("token", "invalid or expired activation token")
			app.failedValidationResponse(w, r, v.Errors)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	// update the user's activation status
	user.Activated = true

	// save the updated user record in our dbs
	err = app.models.Users.Update(user)
	if err != nil {
		switch {
		case errors.Is(err, data.ErrEditConflict):
			app.editConflictResponse(w, r)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	// if everything went successfully, then we delete all activation tokens for the user
	err = app.models.Tokens.DeleteAllForUser(data.ScopeActivation, user.ID)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	err = app.writeJSON(w, http.StatusOK, envelope{"user": user}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}
```

If U try to compile the application at this point, you will get an error cuz the `UserModel.GetForToken()`method doesn't yet exist. Go ahead and create that now.

##### The `UserModel.GetForToken`method

Mentioned above, want the `UserModel.GetForToken()`method to retrieve the details of the use associated with a particular activation token. If there is no matching token found, or it has expired, want this to return a `ErrRecordNotFound`error instead.

```go
func (m UserModel) GetForToken(tokenScope, tokenPlaintext string) (*User, error) {
	hash := sha256.Sum256([]byte(tokenPlaintext))

	query := `
		SELECT users.id, users.created_at, users.name, users.email, 
			users.password_hash, users.activated, users.version
			FROM users
			INNER JOIN tokens
			ON users.id = tokens.user_id
			WHERE tokens.hash = $1
			AND tokens.scope = $2
			AND tokens.expiry > $3`

	args := []any{hash[:], tokenScope, time.Now()}

	var user User

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, query, args...).Scan(
		&user.ID,
		&user.CreatedAt,
		&user.Name,
		&user.Email,
		&user.Password.hash,
		&user.Activated,
		&user.Version,
	)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, ErrRecordNotFound
		}
		return nil, err
	}

	return &user, nil
}
```

### Concurrency -- Practice

In the previous chapter, discussed the foundations of concurrency. Now it's time to look at practical mistakes made by Go developers when working with the concurrency primitives.

#### Propagating an inapropriate context

Contexts are omnipresent when working with currency in Go, and in many situations, it may be recommended to propagate them. However, contxt propagation can sometimes lead to subtle bugs, preventing subfunctions from being corretly executed.

Expose an HTTP handler that performs some tasks and returns a response. Just befor returning the resonse, also want to send it to a Kafka topic. We don't want to penalize the HTTP consumer latency-wise, so we want the publish action to be handled async within a new goroutine. Asseme that we have at our disposal a `publish`function that accepts a context so the action of publishing a message can be intrerupted if the context is canceled, fore.

```go
func handler(w http.ResponseWriter, r *http.Request) {
    response, err := doSomeTask(r.Context(), r)
    if err != nil {
        http.Error(w, erro.Error(), http.StatusInternalServerError)
        return
    }
    go func() {
        err := publish(r.Context(), response)
        //...
    }()
    writeResponse(response)
}
```

Have to know that the context attached to an HTTP request can cancel in differrent conditions -- 

- When the client's connection closes
- In the case of an HTTP/2 request, when the request is canceled
- When the response has been written back to the client

In the first two cases, probably handle things correctly. Fore, if we get a response from `doSomeTask`but the client has closed the connection.

- If the response is written after the Kafka publication, we both return a response and publish a message successfully.
- However, if the response is written before or during the Kafka publication, the message shouldn't be published.

In the latter case, calling `publish`will return an error cuz we returned the HTTP response quickly. How can fix this issue `err := publish(context.Backgound(), resonse)`.

Here, that would work. Regardless of how long it takes to write back the HTTP response, call `publish`. The std package doesn't provide an immediate solution to this problem.

```go
type Context interface {
    Deadline() (deadline time.Time, ok bool)
    Done() <-chan struct {}
    Err() error
    Value(key any) any
}
```

Finally, the values are carried via the `Value`method.

```go
type detach struct {
    ctx context.Context
}

func(d detach) Deadline() (time.Time, bool) {
    return time.Time{}, false
}

func(d detach) Done() <-chan struct {} {
    return nil
}

func (d detach) Err() error {
    return nil
}

func (d detach) Value(key any) any {
    return d.ctx.Value(key)
}
```

Except for the `Value`method that calls the parent context to retrieve a value, the other methods return a *default* value so the context is never considered expired or canceled. `err := publish(detach{ctx:r.Contxt()}, response)`.

Now the context passed to `publish`will never expire or be canceled, but it will carray the parent contxt's values. In summary, propagating a context should be done cautiously.