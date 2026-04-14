# Ridge and Lasso regression --

Ridge and Lasso regression are two powerful techniques used to enhance the performance of linear regression models through what is called *regularization*. Regularization helps prevent overfitting by adding a penality term to the loss function.

To give U a more thorough understanding of this convent, broken it down into 3 parts -- Core concepts, Code logic, and key diffenences.

#### Core concept -- what is Regularization

In standard linear regression, the goal of the model is to minimize the prediction error. However, if there are two many features in the data or if the features are highly correlated, the model can easily become overfitting, which remembers the noise of the training data and causes poor performance on the test data.

*Regularization* is done by add a *penality* to the loss function.

- **Ridge regression (L2 regularization):** The penalty term is the sum of the squares of the coefficients. It makes the coefficient smaller, but not 0.
- **Lasso regression (L1 regularization):** The penalty term is the sum of the absolute values of the coefficients. It not only makes the coefficients smaller, but also directly turns some unimportant coefficients **into 0**, enabling feature selection.

Model components and evaluation tools are imported here.

```py
from sklearn.linear_model import Ridge, Lasso
from sklearn.metrics import mean_squared_error, r2_score

# Create the ridge regression model
ridge_model = Ridge(alpha=1.0)  # alpha controls regularization strength
ridge_model.fit(X_train, y_train)

# Create and fit the Lasso regression model with increased iterations and alpha
lasso_model = Lasso(alpha=10.0, max_iter=10000, tol=0.001)
lasso_model.fit(X_train, y_train)

# make predictions with both models
y_pred_ridge = ridge_model.predict(X_test)
y_pred_lasso = lasso_model.predict(X_test)

# Evaluate the performance
y_pred_linear = linear_model.predict(X_test)

# Calculate metrics for all models
metrics = {
    "Model": ["Ridge Regression", "Lasso Regression", "Linear Regression"],
    "Mean Squared Error": [
        mean_squared_error(y_test, y_pred_ridge),
        mean_squared_error(y_test, y_pred_lasso),
        mean_squared_error(y_test, y_pred_linear),
    ],
    "R-squared": [
        r2_score(y_test, y_pred_ridge),
        r2_score(y_test, y_pred_lasso),
        r2_score(y_test, y_pred_linear),
    ],
}

metrics_df = pd.DataFrame(metrics)
metrics_df = metrics_df.sort_values("Mean Squared Error", ascending=True)

metrics_df["Mean Squared Error"] = metrics_df["Mean Squared Error"].map("{:.2f}".format)
metrics_df["R-squared"] = metrics_df["R-squared"].map("{:.2f}".format)
display(metrics_df)
```

The function of this code to compare the performance of 3 regression models on the test set, and to present the results in a table.

- `Ridge`-- Ridge regression
- `Lasso`-- `Lasso`regression
- `mean_squared_error`-- calculated mean square error
- `r2_score`-- Calculate the cofficient of determination `R^2`.

```py
# Create the ridge regression model
ridge_model = Ridge(alpha=1.0)        # alpha 控制正则化强度
ridge_model.fit(X_train, y_train)

# Create the ridge regression model
ridge_model = Ridge(alpha=1.0) # alpha controls the regularization intensity
ridge_model.fit(X_train, y_train)
```

- `alpha=1.0`-- Regularized strength parameter. The higher the value, the stronger the regularization, and the mode the model coefficient tends to 0.
- Ridge uses `L2`Regularization.

Create an train a Lasso regression model -- 

```py
# Create and fit the Lasso regression model with increased iterations and alpha
lasso_model = Lasso(alpha=10.0, max_iter=10000, tol=0.001)
lasso_model.fit(X_train, y_train)
```

- `alpha=10.0`-- Set relatively large here, which will cause the coefficient many features to become 0 directly
- `max_iter=10000`-- Increases the maximum number of iterations and convergence tolerance.

```py
y_pred_ridge = ridge_model.predict(X_test)
y_pred_lasso = lasso_model.predict(X_test)
y_pred_linear = linear_model.predict(X_test)   # 假设前面已经训练了 linear_model
y_pred_ridge = ridge_model.predict(X_test)
y_pred_lasso = lasso_model.predict(X_test)
y_pred_linear = linear_model.predict(X_test) # Assuming that the linear_model has been trained earlier
```

##### Calculate evaluation metrics and generate a table

```py
metrics = {
    "Model": ["Ridge Regression", "Lasso Regression", "Linear Regression"],
    "Mean Squared Error": [..., ..., ...],
    "R-squared": [..., ..., ...],
}

metrics_df = pd.DataFrame(metrics)
metrics_df = metrics_df.sort_values("Mean Squared Error", ascending=True)  # MSE从小到大排序（最好模型在最上面）
metrics_df["Mean Squared Error"] = metrics_df["Mean Squared Error"].map("{:.2f}".format)
metrics_df["R-squared"] = metrics_df["R-squared"].map("{:.2f}".format)

display(metrics_df)
metrics = {
    "Model": ["Ridge Regression", "Lasso Regression", "Linear Regression"],
    "Mean Squared Error": [..., ..., ...],
    "R-squared": [..., ..., ...],
}

metrics_df = pd. DataFrame(metrics)
metrics_df = metrics_df.sort_values("Mean Squared Error", ascending=True) # MSE sort from smallest to largest (preferably model at the top)
metrics_df["Mean Squared Error"] = metrics_df["Mean Squared Error"].map("{:.2f}".format)
metrics_df["R-squared"] = metrics_df["R-squared"].map("{:.2f}".format)
display(metrics_df)
```

## The Go memory model

The previous section discusssed three main techniques to sync goroutines -- atomic operatins, mutexes, and channels. However, there are some core principles we should be aware of as Go developers. Fore, buffered and unbuffered channels offer differ guarantees.

The Go memory model is a specification that defines the conditions under which a read from a variable in one goroutine can be guaranteed to happen after a writer to the same variable in a different goroutine. In other words, it provides guarantees that developers should keep in mind to avoid data races and force deterministric output. Within a single goroutine, there is no chance of unsynchoronized access. Indeed, the happens-before order is guaranteed by the order expressed by our program.

Within a single goroutine, there is no chance of unsynchronized access.

- Creating a goroutine happens before the goroutine's execution begins.

  ```py
  i := 0
  go func() {
      i++
  }()
  ```

- Conversely, the exit of a goroutine isn't guaranteed to happen before any event. Thus, the following example has a data race -- 

  ```go
  i := 0
  go func() {
      i++
  }()
  fmt.Println(i)
  ```

- A send on a channel happens before corresponding receive from that channel completes, in the next examaple, a parent goroutine increments a variable

  ```py
  i := 0
  ch := make(chan struct{})
  go func() {
      <-ch
      fmt.Println(i)
  }()
  i++
  ch <- struct{}{}
  ```

- Closing channel happens before a receive of this closure. The next example is similar to the previous one, except that instead of sending a message, close the channel.

  ```py
  i := 0
  ch := make(chan struct{})
  go func() {
      <-ch
      fmt.Println(i)
  }()
  i++
  close(ch)
  ```

- The last guarantee regarding channels may be counterintutive at first sight - a receive from an unbuffered channel happens *before* the send to that channel completes.

  ```py
  i := 0
  ch := make(chan struct{}, 1)
  go func() {
      i = 1
      <-ch
  }()
  ch <- struct{}{}
  fmt.Println(i)
  ```

- Let's change the channel to an unbuffered one to illustrate the memory model guarantee - 

  ```go
  i := 0
  ch := make(chan struct{})
  go func() {
      i = 1
      <-ch
  }()
  ch <- struct{}{}
  fmt.Println(i)
  ```

Changing the channel type makes this example data-race-free. here we can see the main difference - the write is guaranteed to happen before the read. The order is follows -- 

```tex
variable increment < channel send < channel receive < variable read
```

By transitivity, we can ensure that accesses to `i`are synchonized and hence free from data races.

### Sending Activiation Tokens

The next step is to hook this to our `registerUserHandler`, so that we generate an activation token a user signs up and include it their welcome email -- similar to this. The most important thing about this email is that we are instructing the user to activate by issuing a `PUT`request to our API.

Having a user click a link to activate via a `GET`request would certainly be more convenient, but in the case of our API it has some big drawbacks. In particular.

- It would violate the HTTP principle that the `GET`method should only be used for *safe* requests which retrieve resources -- not for requests that modify sth.
- It's possible that the user's web browser or antivirus wil pre-fetch the LINK URL in the background.

All-in-all, should make sure that any actions wiich change the state of your application.

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

Update the `registerUserHandler`to generate a new activiaion token, and pass it to the welcome email template as dynamic data, along with the User ID.

```go
func (app *application) registerUserHandler(w http.ResponseWriter, r *http.Request) {
	err = app.models.Users.Insert(user)
	if err != nil {
		switch {
		case errors.Is(err, data.ErrDuplicateEmail):
			v.AddError("email", "a user with this email address already exists")
			app.failedValidationResponse(w, r, v.Errors)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	// After the user record has been created in the dbs, generate a new activation token.
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
        
        // Send the welcome email, passing the map above as dynmic data.
		err := app.mailer.Send(user.Email, "user_welcome.html", data)
		if err != nil {
			// log the error
			app.logger.Error(err.Error())
		}
	})

	// write a JSON response containing the data with a 202 status code
	// This code indicates that the requests has been accepted for processing, but
	// the processing has not completed.
	err = app.writeJSON(w, http.StatusAccepted, envelope{"user": user}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}
```

```sh
BODY='{"name": "Faith Smith", "email": "faith@example.com", "password": "pa55word"}'
curl -d "$BODY" localhost:4000/v1/users
```

##### A standalone endpoint for generating tokens

U may also want to provide a standalone endpoint for generating and sending activiation tokens to your uses. This can be useful if U need to re-rend an activation token, such as when a user doesn't activate their account within the 3-day time limit.

#### Activating a User

In this chapter we're going to move on the part of the activation workflow where we actually activate a user. But before we write any code -- I'd like to quickly talk about the ralationship between uers and tokens in our system.

What we have is known in relational dbs terms as a *one-to-many* REL -- where one user may have many tokens. When you have a one-to-many relationship like this -- you will potentialy want to execute queries against the REL from two sides. In our case, fore, might want to either.

- Retreive the user associated with the token
- Retrieve all tokens associated with a user.

To implment these queries in our code, a clean and clear approach is to update your dbs models to include additional methods like this -- 

```go
UserModel.GetForToken(token)	// retrieve the user associated with a token
TokenModel.GetAllForUser(user)  // Retrieve all tokens associated with a user.
```

The nice thing about this approach is tha the entities being returned align with the main resonsibility of the models, the `UserModel`method is returning a user, and the `TokenModel`method is returning tokens.

##### Creating the `activateUserHandler`

Now that we've got very high-level idea of how we are going to query the user <-> token REL in our dbs models. `PUT /v1/users/activated`.

And the workflow will look like this -- 

1. The user submits the plaintext activation token to the `PUT /v1/users/activated`endpoint.
2. Validate the plaintext token to check that it matches the expected format, sending the client an error message if necessary.
3. We then call the `UserModel.GetForToken()`method to retrieve the details of the user associated with the provided token.
4. We activate the associated user by setting `activated=tue`on the user record and update it in our dbs.
5. Delete all activation tokens for the user from the `tokens`table. Can do this using the `TokenModel.DeleteAllForUser()`method that we made eariler.

## Enhancing components with Hooks

Rendering is the heartbeat of a React application. When sth changes -- the component tree re-renders -- reflecting the latest data as a user interface. `useState`has been our workhorse for describing how our components should be rendering. There are more Hooks that define rules about why and when renering should happen.

#### Introducing `useEffect`

Now have a good sense of what happens when the render a component. A component is simply a function that renders a user interface.

##### Retrieving Colors with `useContext`-- 

The addition of Hooks makes working with context a joy. The `useContext`hook is used to obtain values from context, and it obtains those values we need from the context `Consumer`.

```jsx
export default function ColorList() {
  const { colors } = useContext(ColorContext);
  if (!colors.length) return <div>No Colors Listed. (Add a Color)</div>;
  return (
    <div className="color-list">
      {
        colors.map(color => <Color key={color.id} {...color} />)
      }
    </div>
  );
}
```

##### Stateful context Proviers

The context provider can place an object into context, but it can't mutate the values in context on its own.

```jsx
const ColorContext = createContext();

export default function ColorProvider ({ children }) {
  const [colors, setColors] = useState(colorData);
  return (
    <ColorContext.Provider value={{ colors, setColors }}>
      {children}
    </ColorContext.Provider>
  );
};
```

That isn't the goal, so maybe we should place the alert after the return -- 

```jsx
function Checkbox {
  const [checked, setChecked] = useState(false);

  useEffect(()=> {
      alert(`checked: ${checked.toString()}`);
  })
  return (
    <>
      <input
        type="checkbox"
        value={checked}
        onChange={() => setChecked(checked => !checked)}
      />
      {checked ? "checked" : "not checked"}
    </>
  );

  alert(`checked: ${checked.toString()}`);
};
```

Use `useEffect`when a render needs to cause side effects.

### Understanding a Server Function

```tsx
export function ErrorAlert({
                               error, resetErrorBoundary
                           }: { error: Error, resetErrorBoundary: () => void }) {
    return (
        <div role="alert">
            <h3>Sth went wrong</h3>
            <p>{error?.message || String(error)}</p>
            <button onClick={resetErrorBoundary}>Retry</button>
        </div>
    )
}
```

- `error`-- This is the raised `Error`object that conains all the information in the following props.
- `resetErrorBoundary`-- this allows the state in the `error`boundary to be reset to reattempting rendering.

##### Implementing error boundaries

```sh
npm i react-error-boundary
```

```jsx
export function ErrorAlert({
                               error, resetErrorBoundary
                           }: { error: Error, resetErrorBoundary: () => void }) {
    return (
        <div role="alert">
            <h3>Sth went wrong</h3>
            <p>{error?.message || String(error)}</p>
            <button onClick={resetErrorBoundary}>Retry</button>
        </div>
    )
}
```

Wrap the `ErrorBoundary`from `react-error-boundary`-- so that the fallbck and error reporting are centralized. Create a new file `ErrorBoundary.tsx`in `src/components`

```jsx
export function ErrorBoundary({children,}: {children: ReactNode;}) {
    return (
        <ReactErrorBoundary FallbackComponent={ErrorAlert}
                            onError={(error, info) => {
                                console.log("ErrorBoundary caught an error",
                                    error, info);
                            }}>
            {children}
        </ReactErrorBoundary>
    )
}
```

Called our component `ErrorBoundary`and aliased `ErrorBoundary`from `react-error-boundary`as `ReactErrorBoundary`to prevent them from colliding.

```tsx
export default async function Posts({searchParams}: {
    searchParams: Promise<{ [key: string]: string | string[] | undefined; }>;
}) {
    const criteria = (await searchParams).criteria;
    const resolvedPosts =
        typeof criteria === "string"
            ? await getFilteredPosts(criteria)
            : await getAllPosts();
    const resolvedHeading =
        typeof criteria === "string"
            ? `Posts for ${criteria}`
            : `Posts`;
    return (
        <main>
            <h2>{resolvedHeading}</h2>
            <Suspense fallback={<Loading/>}>
                <ErrorBoundary>
                    <PostList criteria={criteria}/>
                </ErrorBoundary>
            </Suspense>
        </main>
    );
}
```

##### Understanding a Server function

A React server function is exactly as the same suggests -- it's a function that *execute* on the server.

```py
export async function createPost(
    title: string,
    description: string,
) {
    let client: Client | undefined;
    let result: ResultSet | undefined;
    try {
        const client = createClient({
            url: process.env.DB_URL ?? '',
        });
        await client.execute({
            sql: 'INSERT INTO posts(title, description) VALUES (?, ?)',
            args: [title, description],
        });
    } catch {
        return { ok: false };
    } finally {
        if (client) {
            client.close();
        }
    }
    revalidatePath('/posts');
    return {
        ok: true,
        id: result ? result.lastInsertRowid : undefined,
    };
}
```

