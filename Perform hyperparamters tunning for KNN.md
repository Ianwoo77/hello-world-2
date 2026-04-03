# Perform hyperparamters tunning for KNN

To perform hyperparameter tunning for KNN, will use the grid search approach. Grid search is a hyperparameter technique that tests an exhaustive number of combinations of model hyperparameters -- All combinations are testsed, with the resulting combination returned to us the optimal set.

```py
# import the Grid search tool for automatic parameter adjustment
from sklearn.model_selection import GridSearchCV

# the K nearest neighbor classification alg is introduced
from sklearn.neighbors import KNeighborsClassifier

knn = KNeighborsClassifier() # using the default parameters

# Define a hyperparameter grid
# create a KNN model object, currently using the default parameters
param_grid = {
    # The K value to try, there are 5
    'n_neighbors': [3, 5, 7, 9, 11],
    
    # 2 different voting weight stategies
    'weights': ['uniform', 'distance'],
    
    # two different ways to calculate distance
    'metric': ['euclidean', 'manhattan']
}

# Create a grid search
grid_search = GridSearchCV(
    knn, param_grid, cv=5, scoring='accuracy'
)

# Fit the grid search
grid_search.fit(X_train, y_train)

# outputs the best combination of parameters in cross-validation
print("Best Parameters:", grid_search.best_params_)
print("Best cross-validation score:", grid_search.best_score_)
```

The function of this code is *automatically* find the combaintion of hyperparameters that the KNN alg best performs on the current dataset through exhaustive methods. Will try all possible parameter combinations (20 in total) - and select the one with the highest accuracy through 50% cross-validation.

##### Notes

1. This code does not use data normalization, and KNN is very senstive to the scale of features -- it is recommended to add `StandardScaler`when actually using it.
2. There is a lack of test set evaluation in the code, so it is recommended test the real-world performance with `X_test`after getting the best model
3. When parameter range is large, the running time will be longer.

#### Evaluating KNN performance

Evaluating the performance of KNN models is essential for understanding how well the model makes predictions and where it may need improvement. This recipe will cover various techniques for accessing KNN performance, including confusion matrices, precision, recall, and F1-scores.

Will use our toy dataset from before, the Iris dataset, and import a few new functions to help us evalute our model. evaluate our model using cross-validation scores, learning curves, and confusion matrix.

```py
# used to cross-validate the model and return the score for each fold
from sklearn.model_selection import learning_curve, cross_val_score
from sklearn.metrics import confusion_matrix
import seaborn as sns

# Use grid_search.best_estimator_, i.e., the best parameter model found
# by grid search -- to `cross-validate` X_train, and y_train with 50% fold
# cv=5 means that the training set is divided into 5 parts, with 4 parts of training and 1 copy
# of validation, and 5 repeitions
cv_scores = cross_val_score(grid_search.best_estimator_, X_train, y_train, cv=5)
print("Cross-validation scores:", cv_scores)
print("Mean CV score:", cv_scores.mean())

# std diviation is 0.018
print("Standard deviation of CV scores:", cv_scores.std())
```

Empirical Judgement criteria -- 

- `std<0.01`-- very stable
- `std 0.01 ~ 0.03`-- Normal, acceptable
- `std>0.05` -- Volatile and needs to be noted

```py
import numpy as np

train_sizes, train_scores, test_scores = learning_curve(
    grid_search.best_estimator_,
    X_train,
    y_train,
    cv=5,
    train_sizes=np.linspace(0.1, 1.0, 10),
)
```

Plot learning curves -- 

```py
import matplotlib.pyplot as plt

plt.figure(figsize=(10, 6))
plt.plot(train_sizes, np.mean(train_scores, axis=1), label="Training score")

plt.plot(train_sizes, np.mean(test_scores, axis=1), label="Cross-validation score")
plt.xlabel("Training examples")
plt.ylabel("Score")
plt.legend(loc="best")
plt.title("Learning curve")
plt.show()
```

This is typcial KNN model learning curves -- The figure shows the change in models' performance on the training set and cross-validation set as the number of training samples increases.

- Blue Curve -- training score
- Orange Curve -- Cross-validation score

The overall performance of the model is good --- 

- When the training smaples reached 80~100, both curves ended up approaching 1.0
- This shows the KNN model has a strong fitting ability and high final accuracy on the current dataset.

Obvous overfitting phenomemenon -- 

- When training samples are small
  1. The training score qucikly rises above 0.97
  2. The cross-validation score is only .85~0.9
- The two curves are very different -- typical overfit performance.

| 样本数量       | 训练得分 | 验证得分 | 差距 | 结论           |
| -------------- | -------- | -------- | ---- | -------------- |
| 很少（<20）    | 很高     | 较低     | 很大 | **严重过拟合** |
| 中等（40~60）  | 很高     | 逐渐上升 | 中等 | 过拟合在减轻   |
| 较多（80~100） | 很高     | 接近训练 | 很小 | **拟合良好**   |

### Linear SVM Classification

The core concept of SVM is most easily understood through visual aids -- shows a partial Iris dataset presented at the end of chapter 4. The two categories can be easily separated by a straign line.

- The decision boundaries represented by the dotted line are so bad that they can't even properly distinguish between the two categories
- The other two models perform perfectly on the training set, but their decision boundaries are too close to the sample point, so they may not perform well working with new samples.

```py
import numpy as np
import matplotlib.pyplot as plt
from sklearn import datasets
from sklearn.svm import SVC

# 1. Load the Iris dataset
# X shape becomes (150, 2)
iris = datasets.load_iris()
X = iris["data"][:, (2, 3)]  # petal length, petal width

y = iris["target"]

# 2. Keep only Setosa and Versicolor to make it linearly separable
# These two classes are almost linarly separately separable ased on the petal feature
setosa_or_versicolor = (y == 0) | (y == 1)
X = X[setosa_or_versicolor]	  # Now contains 100 samples
y = y[setosa_or_versicolor]

# 3. Train the SVM Classifier (Linear Kernel)
# A very high 'C' value enforces a Hard Margin
svm_clf = SVC(kernel="linear", C=100)
svm_clf.fit(X, y)

# 4. Plotting the data and the "Street"
def plot_svc_decision_boundary(svm_clf, xmin, xmax):
    w = svm_clf.coef_[0]	# weight vector w = [w0, w1]
    b = svm_clf.intercept_[0] # Bias term b

    # At the decision boundary, w0*x0 + w1*x1 + b = 0
    # => x1 = -w0/w1 * x0 - b/w1
    x0 = np.linspace(xmin, xmax, 200)
    decision_boundary = -w[0]/w[1] * x0 - b/w[1]

    margin = 1/w[1]
    gutter_up = decision_boundary + margin
    gutter_down = decision_boundary - margin

    # Plot Support Vectors (the points on the edge of the street)
    svs = svm_clf.support_vectors_
    plt.scatter(svs[:, 0], svs[:, 1], s=180, facecolors='#FFAAAA')

    # Plot the lines
    plt.plot(x0, decision_boundary, "k-", linewidth=2) # Solid line
    plt.plot(x0, gutter_up, "k--", linewidth=2)       # Dashed line
    plt.plot(x0, gutter_down, "k--", linewidth=2)     # Dashed line

plt.figure(figsize=(8, 4))
plt.plot(X[:, 0][y==1], X[:, 1][y==1], "bo", label="Versicolor")
plt.plot(X[:, 0][y==0], X[:, 1][y==0], "yo", label="Setosa")
plot_svc_decision_boundary(svm_clf, 0, 5.5)
plt.xlabel("Petal length", fontsize=14)
plt.ylabel("Petal width", fontsize=14)
plt.legend(loc="upper left", fontsize=14)
plt.title("SVM Large Margin Classification", fontsize=16)
plt.show()
```

- Calculate the decision boundary of the SVM
- Two interval boundaries are calculated that are parallel to the decision boundary and equal in distance
- Make the support vector with stricking circle

##### Soft margin Classification

If we strictly impose that all instances must be off the street and on the correct side, this is called *hard margin classification* - there are two main issues with hard margin classification. First it only works if the data is linearly separable.

- Left - Due to the presence of outliers, it is simply impossible to find a hard interval
- Right - While the hard interval was barely found, it decision boundaries were very different from what swa -- which caused the model to generalize poorly and struggle to cope with new data.

If we strictly require that all instances fall outside the *street* and be on the right side, this is called *hard margin Classification*. There are two main problems with hard interval classification -- 

1. Limitations -- it is only effective if the data is Linearly divisible
2. Sensitity -- it is very sensitive to outliers.

Shows the iris dataset with only one outlier added -- 

- Left -- Due to the precense of outliers - it is simply impossible to find a hard interval
- Right -- While the hard interval was barely found, its decision boudaries were different from what saw, whcih caused the model to generalize poorly and struggle to cope with new data.

##### Why is this dangerous-- 

The picture on the right shows a typical overfitting prototype -- Although this model performs perfectly on the training set, its predictive ability to new data is greatly reduced cuz the decision boundary is skewed by a random outlier. This is why in real-wold engineering-- often tend to use *soft margins* and allow certain interval violations.

This text details the core logic of Soft Margin classification in SVM -- and `C`how hyperparameters balance and variance by controlling *street* width and *violations* -- 

1. Core Concept -- Soft Margin -- Since hard interlocks are extremly sensitive to outliers and cannot handle linearly inseparable data, we introduced *soft intervals*. The goal is to ind a balance between contraditionary goals.
   - Maximize street width - Make the classification boundary as wide as possible
   - Margin Violation -- Minimize the number of instances that fall in the middleware of the street or even on the wrong side.
2. Key variable -- The `C`role hyperparameters -- The Scikit-Learn, hyperparameters `C`are like a *tolerance modifier* that determines how tolerant you are for error.

##### Low `C`Value -- 

- High tolerance -- the model is very tolerant of interval violations
- The result -- the treet became very *wide*
- Advantages -- More instances become the Support vector that supports the street, and the model is more stable easily affected by individual outliers -- the risk of *overfitting is reduced*.
- Disadvantages -- If it is `C`too low, the model will not be able to capture the true features of the dbs cuz it is too broad, resulting in underfitting.

High C value -- 

- Low tolerance -- the model tries to minimize spacing violations and pursues rigorous classification
- The result -- the streets became very narrow
- Pros -- More accurate classification on the training set
- Disadvantges -- the model become very *sensitive*, and it is easy to distort the boundaries to accommodate each point, resulting in overfitting.

```py
from sklearn.datasets import load_iris
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.svm import LinearSVC

# Load the Iris dataset and return it as a DatFrme (as_frame=True)
iris = load_iris(as_frame=True)

# 2. Select two features -- petal length and petal width
# .values converts the DF to a NumPy array for model training
X = iris.data[["petal length (cm)", "petal width (cm)"]].values

# 3. Create binary classification labels: detect if the flower is Iris virginica
# iris.target == 2 represents the Virginica class (0=Setosa, 1=Versicolor, 2=Virginica)
y = (iris.target == 2)  # Iris virginica

svm_clf = make_pipeline(
    # SVMs are senstive to the scale of features. Since they calculate the distance between
    # points to find the widest margin, features with larger raw values would dominate the
    # calclulation.
    StandardScaler(), # Feature standardization
    
    # This is a specialized imp for linear SVMs - is generally faster then using for 
    # large dataset cuz it is optimized specially for the linear case
    LinearSVC(C=1, random_state=42) # Linear support Vector machine
)
svm_clf.fit(X, y)
```

Then, As usual, U can use the model to make predictions -- 

```py
X_new = [[5.5, 1.7], [5.0, 1.5]]
svm_clf.predict(X_new)
svm_clf.decision_function(X_new) # array([ 0.66163411, -0.22036063])
```

Unlike `LogisticRegression, LinearSVC`does not provide a `predict_proba()`method for estimating categorical probabilities -- However, if U use the `SVC`class instead of `LinearSVC`and its `probability`hyperparameters to `True`, the model will fit an additional after training ends, mapping the SVM's decision function scores to the estimated probability.

##### What is SVC

`SVC`is C-Support Vector classification -- It is the most commonly used support vector machine SVM classifier in scikit-learn, based on the libsvm imp, and supports binary and multi-classification tasks.

## Setting up the `Users`Model

Now that our dbs table is set up, going to update our `internal/data`package to contain a new `User`struct, and create a `UserModel`type -- following along, go ahead and create an `internal/data/users.go`file to hold this code:

```sh
go get golang-org/x/crypto/bcrypt@latest
```

```go
type User struct {
	ID        int64     `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	Name      string    `json:"name"`
	Email     string    `json:"email"`
	Password  password  `json:"-"`
	Activated bool      `json:"activated"`
	Version   int       `json:"-"`
}

type UserModel struct {
	DB *sql.DB
}

// Create a custom password type which is a struct containing the plaintext and hashed
// versions of the password for a suer. The plaintext field is a *pointer to a string,
// so that we're able to distuish between a plaintext password not being present in
// the struct at all, versus a plaintext pwd which is empty string ''
type password struct {
    plaintext *string
    has       []byte
}

// The Set() method calculates the bcrypt hash of a plaintext password, and the stores both
// the hash and the plaintext versions in the struct
func (p *password) Set(plaintextPassword string) error {
    hash, err := bcrypt.GenerateFromPassword([]byte(plaintextPassword), 12)
    if err != nil {
        return nil
    }
    p.plaintext = &plaintextPassword
    p.hash = hash
    return nil
}

// The Matches() method checks whether the provided plaintext password matches the hashed
// password stored in the struct, returning true if it matches and false otherwise
func (p *password) Matches(plaintextPassword string) (bool, error) {
    err := bcrypt.CompareHashAndPassword(p.hash, []byte(plaintextPassword))
    if err != nil {
        switch {
        case errors.Is(err, bcrypt.ErrMismatchedHashAndPassword):
            return false, nil
        default:
            return false, err
        }
    }
    return true nil
}
```

- The `bcrypt.GenerateFromPassword()`function generates a bcrypt has of a password using a specific cost parameter -- the higher the cost, the slower and more computationally expensive it is to generate the hash. There is a balance to be struck here -- want the cost to prohibitively expensive for attackers, but also not *so slow* that it harms the user experience of our API. This function returns *hash string* in the format.
- The `bcrypt.CompareHashAndPassword()`function works by re-hashing the provided password using the *same salt* and *cost parameter* that is in the hash string that we are comparing against. The re-hashed value is then checked against the original hash string using `subtle.ConstantTimeCompare()`function, which performs a comparison in constant time -- if they don't match, then it will return `bcrypt.ErrMismatchedHashAndPassword`.

#### Adding Validation Checks

Move on and crate some validation checks for our `User`struct, Specifically, want to -- 

- Check that the `Name`field is not empty string -- and the value is less then 500 bytes long.
- Check that the `Email`field is not the empty string, and that it matches the regular expression for email addresses that added on our `valiator`package eariler in the book.
- If the `Password.plaintext`field is not `nil`-- then check tha the values is not the empty string and is between 8 and 72 bytes long.
- Check that the `Password.hash`field is never `nil`.

```go
func ValidateEmail(v *validator.Validator, email string) {
	v.Check(email != "", "email", "must be provided")
	v.Check(validator.Matches(email, validator.EmailRX), "email", "must be a valid email address")
}

// ValidatePasswordPlaintext validates a plaintext password.
func ValidatePasswordPlaintext(v *validator.Validator, plaintext *string) {
	if plaintext != nil {
		v.Check(*plaintext != "", "password", "must be provided")
		v.Check(len(*plaintext) >= 8, "password", "must be at least 8 bytes long")
		v.Check(len(*plaintext) <= 72, "password", "must not be more than 72 bytes long")
	}
}

func ValidateUser(v *validator.Valiator, user *User) {
    v.Check(user.Name != "", "name", "must be provided")
    v.Check(len(user.Name)<=500, "name", "must not be more than 500 bytes long")
    
    // Call the std ValidateEmail() helper
    ValidateEmail(v, user.Email)
    
    if user.Password.plaintext != nil {
        ValidatePasswordPlaintext(v, *user.Password.plaintext)
    }
    
    if user.Password.hash == nil {
        panic("missing password hash for user")
    }
}
```

##### Creating the `UserModel`

The next step in this process is sitting up a `UserModel`type which isolates the dbs interactions with our PSQL `users`table -- follow the same pattern here that we used for our `MovieModel`, and implement the following methods. fore -- 

- `Insert()`to create a new user record in the dbs
- `GetByEmail()`to retrieve the data for a user with a specific email address
- `update()`to change the data for a specific users.

```go
// Define a custom ErrDuplicateEmail error
var (
    ErrDuplicateEmail = errors.New("dupliate email")
)

// Create a UserModel struct which wraps the connection pool
type UserModel struct {
    DB *sql.DB
}

func(m UserModel) Insert(user *User) error {
    query := `
    	INSERT INTO users (name, email, password_hash, activated)
    	VALUES ($1, $2, $3, $4)
    	RETURNING id, created_at, version
    `
    args := []any{user.Name, user.Email, user.Password.hash, user.Activated}
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

// Update the details for a specific user. notice that we check against the version field to help
// prevent any race conditions during the request cycle, just like we did when updating a movie
// And we also check for a violation of the users_email_key constraint when performing the update
// just like we did when inserting the user record originally
func (m UserModel) Update(use *User) error {
    query := `
    	UPDATE users
    	SET name = $1, email = $2, password_hash=$3, activated = $4, version= version+1
    	WHERE id = $5 and version = $6
    	RETURNING version
    `
    args := []any {
        user.Name,
        user.Emal,
        user.Password.hash,
        user.Activated,
        user.ID,
        user.Version,
    }
    
    ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
    defer cancel()
    
    	err := m.DB.QueryRowContext(ctx, query, args...).Scan(&user.Version)
	if err != nil {
		switch {
		case errors.Is(err, sql.ErrNoRows):
			return ErrEditConflict
		case err.Error() == `pq: duplicate key value violates unique constraint "users_email_key"` 		||err.Error() == `pq: duplicate key value violates unique constraint "users_email_idx"`:
			return ErrDuplicateEmail
		default:
			return err
		}
	}
	return nil
}
```

## State in Component Trees

It's not a great idea to use state in every single component. Having state data distributed throughout too many of your components will make it harder to track down bugs and make changes within your application. This occurs cuz it's hard to keep track of where the state values live within your component tree -- it's easier to understand your app's state, or state for a specific feature, if U manage it from one location. There are several approaches to this methodology, and the first ine we will analyze is storing state at the root of the component tree and passing it down to child components via props.

```json
[
  {
    "id": "0175d1f0-a8c6-41bf-8d02-df5734d829a4",
    "title": "ocean at dusk",
    "color": "#00c4e2",
    "rating": 5
  },
  // ...
]
```

The `color-data.json`file contains an array of 3 colors -- each folor has an `id, title, color`and `rating`. First create a UI consisting of React components that will be used to display this data in  browser.

#### Sending State Down a Component Tree

In this iteration, we will store state in the root of the Color organizer, the `App`component, and pass the `colors`down to child components to handle the rendering. The `App`comonent will be the only component within our app that holds state -- like:

```jsx
import {useState} from "react";
import colorData from "src/assets/color-data.json"

function App() {
    const [colors]= useState(colorData);
    return <ColorList colors={colors}/>;
}
```

The `App`component sits at the root of our tree. Adding `useState()`to this component hooks it up with state management for colors.

```jsx
export default function ColorList({colors=[]}) {
    if(!colors.length) return <div>No colors listed.</div>;
    return(
        <div>
            {
                colors.map(color=> <Color key={color.id} {...color} />)
            }
        </div>
    );
}

export default function Color({title, color, rating}) {
    return(
        <section>
            <h1>{title}</h1>
            <div style={{height:50, backgroundColor:color}} />
            <StarRating totalStars={rating} />
        </section>
    );
}

function App() {
    const [colors]= useState(colorData);
    return <ColorList colors={colors}/>;
}

export default function StarRating({totalStars = 5,
                                   selectedStars = 0,}) {
    return(
        <>
            {createArray(totalStars).map((_, i) => (
                <Star
                    key={i}
                    selected={selectedStars > i}
                />
            ))}
            <p>
                {selectedStars} of {totalStars} stars
            </p>
        </>
    )
}
```

This `StarRating`component has been modified, turned it into a pure component, A pure component is a function component that does not contain state and will render the same user interface given the same props. Made this component a pure component cuz the state for color ratings are stored in the `colors`array at the root of the component tree.

##### Sending Interactions Back up a Component Tree

Rendered a representation of the `colors`array as UI by composing React components and passing data down the tree from parent component to child component via props. What happens if we want to remove a color from the list of a color in our list -- the `colors`are stored in state at the root of our tree.

```jsx
export default function Color({id, title, color, rating, onRemove=f=>f}) {
    return(
        <section>
            <h1>{title}</h1>
            <button onClick={()=>onRemove(id)}><FaTrash /></button>
            <div style={{height:50, backgroundColor:color}} />
            <StarRating selectedStars={rating} />
        </section>
    );
}
```

This solution is great cuz we keep the `Color`component pure. It doesn't have state and can easily be reused in a different part of the app or another application altogether -- The `Color`component is not concerned with what happens when a user clicks the `Remove`button.

Changing the state of the `colors`array causes the `App`component to be rendered with the new list of colors. Those new colors are passed to the `ColorList`component -- which is also rerendered.

```jsx
export default function StarRating({totalStars = 5,
                                   selectedStars = 0,
                                   onRate=f=>f}) {
    return(
        <>
            {createArray(totalStars).map((_, i) => (
                <Star
                    key={i}
                    selected={selectedStars > i}
                    onSelect={() => onRate(i + 1)}
                />
            ))}
        </>
    )
}

export default function Color({
                                  id, title, color, rating, onRemove = f => f,
                                  onRate = f => f
                              }) {
    return (
        <section>
            <h1>{title}</h1>
            <button onClick={() => onRemove(id)}><FaTrash/></button>
            <div style={{height: 50, backgroundColor: color}}/>
            <StarRating selectedStars={rating}
                        onRate={rating => onRate(id, rating)}/>
        </section>
    );
}

export default function ColorList({
                                      colors = [],
                                      onRemoveColor = f => f,
                                      onRateColor = f => f,
                                  }) {
    if (!colors.length) return <div>No colors listed. (Add a Color)</div>;
    return (
        <div className="color-list">
            {colors.map(color => (
                <Color
                    key={color.id}
                    {...color}
                    onRemove={onRemoveColor}
                    onRate={onRateColor}
                />
            ))}
        </div>
    );
}

function App() {
    const [colors, setColors] = useState(colorData);
    return <ColorList colors={colors}
                      onRateColor={(id, rating) => {
                          const newColors = colors.map(color =>
                              color.id === id ? {...color, rating} : color);
                          setColors(newColors);
                      }}
                      onRemoveColor={id => {
                          const newColors = colors.filter(color => color.id !== id);
                          setColors(newColors);
                      }}/>;
}
```

The `App`component will change color rating when the `ColorList`invokes the `onRateColor`property with the `id`of the color to rate and the new rating. We'll use those values to construct an array of new colors by mapping over the existing colors and changing the rating for the color that matches the `id`property. Once we send the `newColors`to the `setColors`function, the state value for `colors`will change and the `App`component will be invoked with a new value for the `colors`array.

Once the state of our `colors`array changes, the UI tree is rendered with the new data. The new rating is reflected back to the user via red stars.

#### Building Forms

For a lot of us, being a web developer means collecting large amounts of information from users with forms. If this sounds like your job, then you will be building a lot of form components with React.

```jsx
<form>
    <input type="text" placeholder="color title..." required/>
    <input type="color" required/>
    <button>ADD</button>
</form>
```

This `form`element has 3 child element -- two `input`elements and a `button`, the first `input`element is a text input that will be used to collect `title`value for new colors. The second `input`element is an HTML color input that will allow users to pick a `color`from a color wheel.

##### Using Refs

When it's time to build a form component in React, there are several patterns avaialble to U. One of these patterns involves accessing the DOM node directly using a React feature called `refs`. React provides us with a `useRef`hook that we can use create a `ref`-- use this hook with building the `AddColorForm`component -- 

```jsx
export default function AddColorForm({ onNewColor = f => f }) {
  const txtTitle = useRef();
  const hexColor = useRef();

  const submit = e => { ... }
  return (...)
}
```

