# Introduction to scikit-learn’s design philosophy

Scikit-learn’s success is built on a Lego-like philosophy that prioritizes a seamless user experience through a standardized API.

- The Unified interface
  1. `fit()`-- used for training models or calculating parameters.
  2. `predict()`-- Used for generating outputs from new data.
  3. `transform()`-- Used for modifying data.
- Modularity and pipelines -- `Pipeline()`classs is a standout feature that allows developsers to chain preprocessing and modeling steps into a single, cohesive object.
  1. Efficiency -- Streamlined code reduces development time.
  2. Reproducibility -- workflows are eaiser to track and deploy without errors.
  3. Readability -- Complex processes remain organized and transparent.

#### Understanding estimators

To summarize, machine learning is great for -- 

- Problems for which existing solutions require a lot of fine-tuning or long lists of rules.
- Complex problems for which using a traditional approach yields no good solution
- Fluctuating environments.

```python
import matplotlib.pyplot as plt

plt.rc('font', size=12)
plt.rc('axes', labelsize=14, titlesize=14)
plt.rc('legend', fontsize=12)
plt.rc('xtick', labelsize=10)
plt.rc('ytick', labelsize=10)
```

#### Training Supervision

ML systems can be classified according to the amount and type of supervision they get during training. There are many categories, but we’ll discuss the main ones: supervised learning, unsupervised learning, self-supervised learning, semi-supervised learning, and *reinforcement* learning.

- Supervised learning -- The training set you feed to the alg includes the desired solutions -- called labels. Typical is *classification*. Another is to predict a *target* numeric value. Or, *regression*. And note that some regression models can be used for classifiction as well, and vice versa.
- Unsupervised learning -- May want to run a clustering alg to try to detect groups of similar visitors. And:
  - Hierarchical clustering -- like a tree map, which can not only divide large categories but also subcategories.
  - Targeting -- Most classic business of clustering.
  - Visualization and dimensionality reduction -- Discover the hidden structure of your data.

For unsupervised learning -- one task related to this is *Dimensionality reduction* -- which aims to simplify data without losing too much info.

- Imp -- One way to do this is to merge multiple related features into one.
- Example description -- A car’s mileage is often strongly correlated with its age.
- Terminology -- called *feature extraction*.

And the *anomaly detection* and *novelty Detection*. 

- The system is primarily exposed to normal instances during training and thus learns to recognize what is normal.
- Novelty Detection -- Novelty detection is very similar to anomaly detection -- but its goal is to identify sth new that is different from all the data in the training set. And it requires that the training dataset be *absolutely* Clean. Means that the training set can only have normal data.

#### Semi-supervised learning -- 

Use a small number of labels to do big things. And most semi-supervised learning algorithms are a combination of unsupervised and supervised algorithms.

1. Use a clustering alg to group similar instances
2. Propagate the tags that are already in the category to all untagged instances in the same cluster.
3. Once the entire data set is labeled, Can train using any *supervised* learning algorithm.

| **Types of learning**        | **Logic**                                               | **Data requirements**                 |
| ---------------------------- | ------------------------------------------------------- | ------------------------------------- |
| **Supervised learning**      | The teacher teaches one, and the student learns one     | All have labels                       |
| **Unsupervised learning**    | Students observe by themselves and find common ground   | None of them have labels              |
| **Semi-supervised learning** | *The teacher clicked, and the students drew inferences* | *Minimal labels + lots of label-free* |

#### Self-supervised Learning -- 

Its core idea is to automatically generate a *fully labeled dataset from a completely unlabled dataset*. Once the data is automatically labeled, can train the model using any std supervised learning alg. And the Self-supervised learning is usually just a pre-training process that praves the way for the final actual task.

And the *reinforcement learning* is a completely different field. In this context, the learing system is called an agent. Can observe the environment, select and execute actions, and exchange them for rewards.

| Characteristics                    | Instance-Based Learning                                      | Model-Based Learning                                         |
| :--------------------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| **Attitude towards training data** | Save all the data and "memorize it"                          | After finding out the patterns behind the data, the original data is usually discarded |
| **Ways to predict new data**       | Take the new data and the old data of the inventory to calculate "distance" or "similarity" | Plug the new data into the summarized "model/formula" for calculation |
| **Popular analogy**                | Find similar cases in the past and do so                     | Summarize the rules and set formulas when encountering new problems |

```python
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from sklearn.linear_model import LinearRegression

# Download and prepare the data
data_root = "https://github.com/ageron/data/raw/main/"
lifesat = pd.read_csv(data_root + "lifesat/lifesat.csv")
X = lifesat[["GDP per capita (USD)"]].values
y = lifesat[["Life satisfaction"]].values

# Visualize the data
lifesat.plot(kind='scatter', grid=True,
             x="GDP per capita (USD)", y="Life satisfaction")
plt.axis([23_500, 62_500, 4, 9])
plt.show()

# Select a linear model
model = LinearRegression()

# Train the model
model.fit(X, y)

# Make a prediction for Cyprus
X_new = [[37_655.2]]  # Cyprus' GDP per capita in 2020
print(model.predict(X_new)) # outputs [[6.30165767]]
```

## Ignoring when to wrap an error

Since Go 1.13, the `%w`directive allows us to wrap errors conveniently. But some developers may be confused about when to wrap an error -- remind ourselves that error wrapping is and then to use it.

```go
type BarError struct {
    Err error
}
func (b BarError) Error() string {
    return "bar failed:" + b.Err.Error()
}
if err != nil {
    return BarError{Err: err}
}
if err != nil {
    return fmt.Errorf("bar failed: %v", err)
}
```

Came with a directive to wrap an error and a way to check whether the wrapped error is of a certain type of `errors.As`. This function recursively unwraps an error and returns `true`if an error in the chain matches the expected type.

- Use `errors.Is()`when U want to check if an error matches a specific *value*.
- Use `errors.As()`when U want to check if an error is of a specific *type* -- and *want to extract it to access its fields*.

Fore:

```go
package main

import (
	"errors"
	"fmt"
)

// A sentinel error
var ErrDatabaseConnection = errors.New("database connection lost")

func fetchData() error {
	// Wrapping the original error with more context
	return fmt.Errorf("fetchData failed: %w", ErrDatabaseConnection)
}

func main() {
	err := fetchData()

	// WRONG way (will evaluate to false because of the wrapping):
	if err == ErrDatabaseConnection {
		fmt.Println("This won't print")
	}

	// CORRECT way:
	if errors.Is(err, ErrDatabaseConnection) {
		fmt.Println("Reconnecting to the database...") // This will print!
	}
}
```

- When to use `errors.As()`-- Goal -- Are U this type of error, if so, give me your details -- Use `errors.As()`when U have a custom error `struct`that contains extra data and U need to extract that data. It unwrap the error *onion* looking for a specific *type*. If it finds it, assigns the inner error to your target variable so U can use its special fields.

```go
package main

import (
	"errors"
	"fmt"
)

// A custom error struct type
type HTTPError struct {
	StatusCode int
	Message    string
}

// Implement the error interface
func (e *HTTPError) Error() string {
	return fmt.Sprintf("status %d: %s", e.StatusCode, e.Message)
}

func fetchAPI() error {
	httpErr := &HTTPError{StatusCode: 404, Message: "user not found"}
	// Wrapping the custom error
	return fmt.Errorf("api call failed: %w", httpErr)
}

func main() {
	err := fetchAPI()

	// We declare a variable of the specific error type we want to find
	var targetErr *HTTPError

	// We pass the POINTER to targetErr (&targetErr)
	if errors.As(err, &targetErr) {
		// If found, targetErr is populated! We can now use its specific fields:
		fmt.Printf("Uh oh, HTTP Error %d occurred!\n", targetErr.StatusCode)
		
		if targetErr.StatusCode == 404 {
			fmt.Println("Let's show a 404 page to the user.")
		}
	} else {
		fmt.Println("It was some other type of error.")
	}
}
```

| Feature                    | `errors.Is(err, target)`                   | `errors.As(err, &target)`                                    |
| :------------------------- | :----------------------------------------- | :----------------------------------------------------------- |
| **What it checks**         | Error **Value**                            | Error **Type**                                               |
| **Real-world analogy**     | "Are you exactly John Doe?"                | "Are you a Doctor? If yes, show me your medical license."    |
| **Target argument**        | An error variable (e.g., `os.ErrNotExist`) | A **pointer** to a variable of the desired custom error type |
| **Pre-Go 1.13 equivalent** | `if err == target`                         | `if customErr, ok := err.(*CustomError); ok`                 |
| **Returns**                | `boolean`                                  | `boolean` (and modifies the target variable)                 |

