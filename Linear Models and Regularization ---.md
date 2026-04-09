# Linear Models and Regularization ---

Linear regression was probably one of the earliest data models we came into contact with during our formal studies. U may not realize this at the time -- but linear regression is essentially a simple machine learning model that tries to find mathematical REL between data points and express them as linear equuations.
$$
y = \beta_0 + \beta_1 x + \epsilon
$$

#### Introductional linear models

Linear models serve as the backbone for many predictive modeling techniques, offering an upfront approach to understanding rels between variables -- this recipe provides a foundation for understanding more complex linear techniques and their importace in predictive modeling, setting the stage for advanced topics such as regularized regression and logisitic regression.

```py
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.datasets import make_regression

X, y = make_regression(
    n_samples=1000, n_features=100, n_informative=10, noise=20, random_state=123
)

for i in range(50, 100):
    # represents all rows in column i
    # generates 1000 random numbers from normal distribution
    X[:, i] = X[:, i - 50] + np.random.normal(0, 0.1, size=1000)
feature_name = [f"feature_{i}" for i in range(100)]
X_plot = X[:, 0].reshape(-1, 1)  # 1D to 2D
y = y * 1000  # Scale up the target
y = (y + np.sin(X_plot.ravel()) * 150 + np.exp(X_plot.ravel() / 10))

# plot al 100 feature's distributions quickly
plt.figure(figsize=(10,6))
plt.scatter(X_plot, y, alpha=0.5)
plt.xlabel('Feature 0')
plt.ylabel('Target')
plt.title('Synthetic Data')
plt.show()
```

#### How to do it -- 

Implementation of a linear regression model is straightfoward, use the `train_test_split()`function to split data into training and testing sets, and then fit a linear regression model to the training sets, and then fit a linear regression model on the training data.  Finally, will evaluate the model's performance using `MSE`and `R-square`metrics -- can also visualize the model's predictions on the test set visualize how well it fits to the data.

```py
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error, r2_score

# Split the data into training and testing sets
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=123
)

# Create and fit a linear regression model
linear_model = LinearRegression()
linear_model.fit(X_train, y_train)

# Make predictions on the test set
y_pred = linear_model.predict(X_test)

# Evaluate the performance using the MSE and R^2
mse = mean_squared_error(y_test, y_pred)
r2 = r2_score(y_test, y_pred)
print(f"Mean Squared Error: {mse: .2f}")
print(f"R-squared: {r2:.2f}")

# visualize the data regression line
plt.figure(figsize=(10, 6))
plt.scatter(X_test[:, 0], y_test, color="blue", alpha=0.5, label="Test Data")
plt.scatter(X_train[:, 0], y_train, color="green", alpha=0.5, label="Train Data")

# Sort the data for a smooth line plot
X_line = np.linspace(df["feature_0"].min(), df["feature_0"].max(), 100).reshape(-1, 1)
X_line_full = np.zeros((100, len(feature_name)))
X_line_full[:, 0] = X_line.ravel()

y_line = linear_model.predict(pd.DataFrame(
    X_line_full, columns=feature_name
))
plt.plot(X_line, y_line, color='red', label='Regression Line')
plt.xlabel('feature_0')
plt.ylabel('target')
plt.title('Linear Regression Fit')
plt.legend()
plt.show()
```

In Python's Numpy library, the correct method name is `ravel()`. Flattens a multidimensional array into a 1D array.

##### Why do U need in your code -- 

```py
X_line = np.linspace(...).reshape(-1, 1) # 这是一个列向量（二维，形状如 [100, 1]）
X_line_full[:, 0] = X_line.ravel()        # 赋值给 X_line_full 的第一列
```

- `X_line`is created with `.reshape(-1, 1)`which is a 2D array
- `X_line_full[:,0]`represents the first column of the array, which is often treated as a 1D array in Numpy's Slicing operation.
- To mtch the shape use `reval()`to change the `X_line`from (100,1) to (100,), which is safer and more explicit.

##### Core features of `ravel()`-- 

- Continuity -- it arranges all elements of the array into a bar in row-first `C-style`or column -first order
- view vs copy -- the most important point of `ravel()`-- it returns a `view`of the original array.

## Using a helper Function

If Need to execute a lot of background tasks in your application, it can get tedious to keep repeating the same panic recovery code -- and there is a risk tht might forget to include it altgether.

```go
func (app *application) background(fn func()) {
	// increment the WaitGroup Counter
	app.wg.Add(1)
	go func() {
		defer app.wg.Done()
		// recover any panic
		defer func() {
			if err := recover(); err != nil {
				app.logger.Error(fmt.Sprintf("%v", err))
			}
		}()
        
        // Execute the arbitrary function that we passed as the parameter
		fn()
	}()
}
```

The `background()`helper leverages the fact that the Go has *first-class functions*, which means that functions can be assigned to variables and *passed as parameters* to other funcitons. In this case, we've get up the `background()`helper so that it accepts any function with the signature `func()`as a parameter and stores it the variable `fn`. Then -- 

```go
func (app *application) registerUserHandler(w http.ResponseWriter, r *http.Request) {
    // Use the background helper to execute an anonymous function that sends the welcome email
    app.background(func(){
        err = app.mailer.Send(user, Email, "user_welcome.html", user)
        if err != nil {
            app.logger.Error(err.Error())
        }
    })
    err = app.WriteJSON(w, http.StatusAccepted, envelope{"user": user}, nil)
    if err != nil {
        app.serverErrorResponse(w, r, err)
    }
}
```

```sh
BODY='{"name": "Dave Smith", "email": "dave@example.com", "password": "pa55word"}'
curl -w '\nTime: %{time_total}\n' -d "$BODY" localhost:4000/v1/users
```

#### Graceful shudown of Background tasks

Sending our welcome email in the background is working, but there is still an issue we need to address. When we initiate a graceful shutdown of our application, it won't *wait* for any *background* goroutine. Fortunately, can prevent this by using Go's `sync.WaitGroup`functionality to cooridinate the graceful shutdown and our backgound goroutines.

When want to wait for a collection of goroutines to finish their work, the principal tool to help with this is the `sync.WaitGroup`type -- The way that it works is conceptually a bit like a *counter*. FORE:

```go
func main() {
    // Declare a new WaitGroup
    var wg sync.WaitGroup
    for i := 1; i<=5; i++ {
        // Increment the WaitGroup counter by 1
        wg.Add(1)
        go func() {
            // Defer a call to wg.Done() to indicate that the background goroutine has
            // complete when this function returns
            defer wg.Done()
            fmt.Println("hello from a goroutine")
        }()
    }
    wg.Wait()
    fmt.Println("all goroutine finished")
}
```

##### Fixing our application

update our app to incorporate a `sync.WaitGroup`that coordinate our graceful shudown and background goroutines -- begin in our `cmd/api/main.go`file -- edit the `applicaiton`struct to contain a new `sync.WaitGroup`-- 

```go
type application struct {
	config config
	logger *slog.Logger
	models data.Models
	mailer mailer.Mailer // update the application struct to include a mailer field
	wg     sync.WaitGroup
}
```

Next let's head to the `cmd/api/helpers.go`file and update the `app.background()`helper so that the `sync.WaitGroup`is incremented each time before launch a background goroutine, and then decremented when it completes -- like this.

```go
func (app *application) background(fn func()) {
	// increment the WaitGroup Counter
	app.wg.Add(1)
	go func() {
        // use defer to decrement the WaitGroup counter the goroutine returns
		defer app.wg.Done()
		// recover any panic
		defer func() {
			if err := recover(); err != nil {
				app.logger.Error(fmt.Sprintf("%v", err))
			}
		}()
		fn()
	}()
}
```

Then the final thing we need to do it update our graceful shutdown functionality so that it uses our new `sync.WaitGroup`to wait for any background goroutines before terminating the application. Can do that by adapating our `app.server()`method like so -- 

```go
func (app *application) serve() error {
	srv := &http.Server{
		Addr:         fmt.Sprintf(":%d", app.config.port),
		// ...
	}

	// create a shutdown channel, use this to receive any errors returned
	// by graceful  shutdown function
	shutdownError := make(chan error)

	go func() {
		quit := make(chan os.Signal, 1)
		signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
		s := <-quit

		app.logger.Info("caught signal", "signal", s.String())

		ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
		defer cancel()
        
		err := srv.Shutdown(ctx)
		if err != nil {
			shutdownError <- err
		}

		// log a message to say that we are waiting for any background goroutine to complete
		app.logger.Info("waiting for background goroutines to complete...")
		app.wg.Wait()
		shutdownError <- nil
	}()

	// Likewise log a string server message
	app.logger.Info("starting server", "addr", srv.Addr, "env", app.config.env)

	// Calling Shutdown() on the server will cause ListenAndServe() to immediately return
	// an http.ErrServerClosed error, so can see this error
	err := srv.ListenAndServe()
	if !errors.Is(err, http.ErrServerClosed) {
		return err
	}

	// otherwise, wait to receive value from Shutdown() on the shutdownError channel
	// if return value is an error, know that there was a problem
	err = <-shutdownError
	if err != nil {
		return err
	}

	// at this point, log a message to say that we're ready for the next one
	app.logger.Info("stopped server", "addr", srv.Addr)
	return nil
}
```

To try this out, go ahead and restart the API and then send a request t the `POST /v1/users`endpoint immediately followed by a `SIGTERM`signal

```sh
BODY='{"name": "Edith Smith", "email": "edith@example.com", "password": "pa55word"}'
curl -d "$BODY" localhost:4000/v1/users & pkill -SIGTERM api &
```

#### User Activation

At the moment a user can register for an account with our *Greenlight* API -- don't know for sure that the email address they provided during regisration *actually belongs to them*.

So, in this section of the book, we are going to build up the functionality to confirm that a user used their own real email address by including *account activation* instructions in their welcome email. There are *several reasons* for having an activation step, but the main benefits are that it adds an additional hoop for bots to jump through, and helps prevent abuse by people who register with a fake email address or one that dosn't belong to them.

1. As part of the registration proces for a new user we will create a cryptographically-secure random *activation token* this is impossible to guess.
2. We will then store a hash of this activvation token a new `tokens`table, alongside the new user's ID and expiry time for the token.
3. We will send the original (unhashed) activation token to the user in their welcome email.
4. The user subsequently submits their token to a new `PUT /v1/users/actiated`endpoint.
5. If the hash of the token exists in the `tokens`table and hasn't expired, then we will updte the `activated`status for the relevant user to `true`.
6. Lastly, delete the activation tokens from our `tokens`table so that it can't be used again.

In this secion of the book, learn how to -- 

- Implementing a secure's account acviation's workflow which verifies a new user's email address.
- Generate cryptographically-scure random tokens using Go's `crypto/rand`and `encoding/base32`packages.
- Generate fast hashes of data using the `crypto/sha256`package.
- Implementing patterns for working with cross-table REL in your dbs, including setting up FKs and retrieing related data via SQL `JOIN`queries.

#### Setting up the Tokens Dbs Table

Begin by creating a new `tokens`table in your dbs to store the activation tokens for our users.

```sh
migrate create -seq -ext .sql -dir ./migrations create_tokens_table
```

```sql
CREATE TABLE IF NOT EXISTS tokens (
    hash bytea PRIMARY KEY,
    user_id bigint NOT NULL REFERENCES users ON DELETE CASCADE,
    expiry timestamp(0) with time zone NOT NULL,
    scope text NOT NULL
);
```

- The `hash`column will contain a SHA-256 hash of the activation token. It's important to emphasize that we will only store a hash of the activation token in our dbs -- not the activation token itself. Want to hash the token before storing it for the same reason that we bcrypt a user's password.
- The `user_id`column will contain the ID of the user associated with the token. Use the `REFERENCES user`syntax to create a FK contraint against the primary key of our `users`table. A common alternative `ON DELETE CASCADE`is `ON DELETE RESTRICT`.
- The `expiry`Column will contain the time that we consider a token to be expired and no longer valid.
- The `scope`column will denote what *purpose* the token can be used for. Later in the book we'll also need to create and store *authentication tokens*, and most of the code and storage requirements.

## Enhancing Components with Hooks

Rendering is the hearteat of a React application. When sth changes, the component tree rerenders, reflecting the lastest data as a user interface. `useState`has been our workhorse for describing how our components should be rendering. There are more hooks that define rules about why and when rendering should happen. There are more Hooks that enhance rendering performance.

`useState, useRef, useContext`and `useInput, useColors`-- there is more where that came from, though, React comes with more Hooks out of the box. `useEffect`and `useLayoutEffec`and `useReducer`. All of these are vital when building applications -- also look at `useCallback`and `useMemo`.

#### Introducing `useEffect`

Now have a good sense of what happens when we render a component - A component is imply a function that renders a user interface. Renders occur when the app first loads and when props and state values change. Consider a simple component, A user can check and uncheck the box, but how might we alert the user that the box has been checked -- try this with an `alert`.

```jsx
function Checkbox() {
    const [checked, setChecked] = useState(false);
    alert(`checked: ${checked.toString()}`);
    return (
        <>
            <input
                type="checkbox"
                value={checked}
                onChange={() => setChecked(!checked)}
            />
            {checked ? "Checked" : "Not Checked"}
        </>
    );
	// will not render until the user clicks ok button.
	// Can't call alter after the render cuz the code
	alert(`checked: ${checked.toString()}`);
}
```

Use `useEffect`when a render needs to cause side effects. Think of a side effect as sth that a function does that isn't part of the return. The function is the `Checkbox`-- the `Checkbox`function renders UI -- might want the component to do more than that. Those things we want the component to do other than return UI are called *effects*.

An `alert, console.log()`an interaction with a browser or native API is not part of the render -- It's not part of the return. In a React app, though, the render affects the results of one of these events.

##### The Dependency Array

`useEffect`is designed to work in conjunction with other stateful Hooks like `useState`and the heretofore unmentioend `useReducer`.

```tsx
import './App.css'
import {useEffect, useState} from "react";

function App() {
    const [val, set]= useState('');
    const [phrase, setPhrase] = useState('example phrase');
    
    const createPhrase = ()=> {
        setPhrase(val);
        set('');
    };

    useEffect(() => {
        console.log(`typing ${val}`);
    });
    useEffect(() => {
        console.log(`phrase ${phrase}`);
    });
    return(
        <>
            <label>Favorite phrase:</label>
            <input value={val}
                   placeholder={phrase}
                   onChange={(e) => set(e.target.value)} />
            <button onClick={createPhrase}>send</button>
        </>
    )
}

export default App
```

