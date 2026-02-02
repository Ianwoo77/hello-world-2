# Scikit-learn’s design philosophy

Consistency, Simplicity, modularity, and reusability. Offers a unified interface for a broad range of ML algorithms, where most models follow a similar pattern, the use `fit()`to train the model, `predict()`to make predictions, and `transform() `to manipulate the data. This consistency allows users to easily switch between models, improving productivity and reducing the learning curve.

Designed to be modular, meaning individual components such as estimators, transformers, and pipelines can be combined and reused across different tasks.

For the `Pipeline`-- highlights its advantages in improving productivity, code reusability, and scalability, and concludes with trivial about the library’s naming prounication.

Without pipeline, need to do it manually, in ML, raw data cannot be directly thrown to model training and must be preprocessed -- Cuz -- 

- Scaling -- fore, standardizing data or normalizing to make features of different dimensions comparable.
- Encoding -- fore `OneHotEncoder`

Without pipeline, need to do it manually, first scale, record, then scale the test set, and then train the model. This is just error-prone. With pipeline in place, can concatenate -- scale-> encoding -> modeling into a *single object* when you call `fit()`, it automatically processes all the steps in internally in order.

#### Understanding estimators

Esimators are objects in Py’s OOP that implement algorithms for learning from data and are consistent across the entire library. In scikit-learn, follows a simple and intuitive interface -- `fit()`and `predict()`-- both of which were mentioned previously. The `fit()`trains the models by learning from the data, while `predict()`is used to make predictions one new data based on trained model. Fore:

```python
from sklearn.linear_model import LinearRegression
import numpy as np

X = np.array([[1], [2], [3], [4], [5]])
y = np.array([1, 2, 3, 3.5, 5])
model = LinearRegression()
model.fit(X,y)
X_new = np.array([[6], [7]])
y_pred = model.predict(X_new)
print(y_pred)
```

The library also provides a nice shotcut method, fit_predicat(), that combines these operations into a single API call, very useful tool - `fit_predict()`-- When want to obtain predictions within the same dataset the model was trained on. This is often the case in unsupervised learning, fore `KMeans`. And this is not to say you can’t use `fit_predict()`in unsupervised learning scenarios -- Dbs can still be split into training, validation, and testing sets.

| **Method**            | **Goal**                                          | **Common Use Case**                                          |
| --------------------- | ------------------------------------------------- | ------------------------------------------------------------ |
| **`fit()`**           | Calculate parameters (means, coefficients, etc.). | Training a Classifier (e.g., SVM, Random Forest).            |
| **`predict()`**       | Apply learned parameters to new data.             | Making real-world forecasts on new inputs.                   |
| **`fit_predict()`**   | Learn and label the dataset simultaneously.       | Clustering (K-Means) or Outlier Detection (Isolation Forest). |
| **`fit_transform()`** | Learn parameters and modify the data shape/scale. | Scaling data (StandardScaler) or PCA.                        |

Even in unsupervised learning, if you plan to deploy your model to a production environment to categoize new incoming data, you should still use `fit()`on your initial batch and `predict()`on the new stream.

```python
from sklearn.cluster import KMeans

X= np.array([[1], [2], [3], [4], [5]])

# Kemans clustering example
kmeans = KMeans(n_clusters=2)
labels = kmeans.fit_predict(X)
print(labels)
```

#### Transformers and the `transform()`method

`transformers`are tools that modify data by applying transformations such as scaling, normalizations, or encoding to prepare it for modeling. Each transfomer follows a  consistent interface, using the `fit()`method to learn any necessary parameters from the data and the `transform()`method to apply those transformations. Fore, `StandardScalar()`calculates the mean and std deviation during `fit()`and use those values to transform the data by scaling it. Data transformation provide several benefits when applied to ML scenarios -- First, many models presuppose data to be normally distributed, free of outliers -- and so on. Second, most real-world dataset does not come in this neat-and-tidy format and require some massaging before modeling occurs. FORE:

```python
from sklearn.preprocessing import StandardScaler
import numpy as np

X= np.array([[1,2], [3, 4], [5, 6]])

# create a standard scaler instance
scaler = StandardScaler()
# fit the scalar on the data
scaler.fit(X)
X_scaled = scaler.transform(X)
print(X_scaled)
```

And, `fit_transform()`allows users to perform both step in one command, making preprocessing workflows more efficient. When to use `fit_tansform()`and `fit()`with `transform()`separately dpends on the task at hand. Typically, we should apply the `fit_transform()` to our training data if we want to transform our data immediately basedon the calculated transformation. However, when applying transformations to the test dataset, wouldn’t want to reapply the `fit()`method.

```python
scaler = StandardScaler()
# fit and transform the scalar on the data
scaler.fit_transform(X)
```

#### Handling custom estimators and transformers -- 

scikit-learn’s API is designed to be extensible, allowing developers to create custom estimators and transformers the integrte seamlessly into existing workflows -- by subclassing `BaseEstimator()`and `mxiin`classes. Can implement the `fit()`and `transform()`or `fit()`and `predict()`methods.

##### Mixin classes -- 

in Scikit-learn, a mixin is a way to extend the fundationality of classs without using traditional class inheritance found in Py and other OOP language. Each custom estimator should follow the scikit-learn interface by implementing the `fit()`and `transform()`or `fit()`and `predict()`methods, ensuring compatibility with tools as `GridSearchCV()`and `Pipeline()`.

- Not just use, but build -- Not only to call ready-made models, but also write custom components that meet the scikit-learn standard.
- `check_is_fitted()`-- Utility function -- when writing a custom model, need to make sure that the user has already called `fit()`before calling `predict()`-- is used to check whether the model has been trained to prevent low-level errors predicted without training.
- Eco-compatibility -- If follow the scikit-learn interface specification, your code can directly enjoy scikit-learn’s advanced features, such as *cross-validation* and *hyperparameters Search*.

##### Pipeline and workflow automation

- Linear vs loop -- traditional ML code tends to be linear, wash -> training -> prediction. However, the article points out that the real production environment is cyclical, including monitoring, continous training, and continuous interation/deployment (CI/CD).
- Cohesive object -- The core value of a pipeline is to package a series of loose steps such as proprocessing, feature selection model traiing into a single object.

#### Common attributes and methods

As model complexity grows, it becomes harder and harder to look inside and understand a model’s inner workflows - scikit-learn model share several key attributes and methods that provide valuable insights int how a model has learned from data. Such as `coef_`and `intercept_`. And `.coef_`represent `w`and `intercept_`represent `b`, fore 
`y= wx + b`. and `.feature_importances_`for table like:

| **Model Type**          | **Key Attribute**      | **What it Tells You**                                |
| ----------------------- | ---------------------- | ---------------------------------------------------- |
| **Linear Regression**   | `coef_`                | The "slope" or impact of each feature. `w`           |
| **Logistic Regression** | `intercept_`           | The baseline probability when features are zero. `b` |
| **Decision Trees**      | `feature_importances_` | Which features were used most to split the data.     |
| **Random Forest**       | `estimators_`          | Access to the individual trees within the forest.    |

The `score()`method -- One of the most helpful feature for beginners and pros alike is that every estimator has a built-in scoring mechanism - don’t always need to import `mean_squared_error`or `accuracy_score`separately.

- For `Regressors`-- calculate the Coefficient of Determination. 1 is best
- for Classifiers - calculates the Man accuracy

```python
X = np.array([[1], [2], [3], [4], [5]])
y = np.array([1, 2, 3, 3.5, 5])
model = LinearRegression()
model.fit(X, y)

print('Cofficients', model.coef_) # w

# Accessying y-intercept
print('intercept', model.intercept_) # b
print("model R-sqared:", model.score(X, y))
```

#### HyperParameter tuning with search methods

Hyperparameter tuning is crucial for optimizing candidate ML models, and scikit-learn makes this process easier with a variety of built-in search methods. The library provides two popular methods, `GridSearchCV()`and `RandomizedSearchCV()`-- in easy-to-implement APIs.

##### Parameters vs. Hyperparameters

Parameters are learned by the model itself during training, And Hyperparameters are configurations that you set before training -- the default hyperparameters are optimal -- Tuning is about finding a set of configurations that will allow the model to perform best on a particular dataset.

There are the most two commonly used tunning methods in scikit-learn - 

- `GridSearchCV`-- Violent Action -- pros -- guaranteed to find the optimial solution within your specified range -- cons, extremely slow.
- `RandomizedSearchCV`-- Random sampling -- U give a parameter distribution from which it randomly selects fixed number for combinations to try -- pros -- fast and high efficientcy -- cons, absolute optimal may be missed.

##### Successive Halving -- 

Advanced acceleration strategy for large datasets -- `HalvingGridSearchCSV`and `HalvingRandomSearchCSV()`. Also, allows a manual approach to setting hyperparameters if u wish to adjust default values for your own training purposes -- `set_params()`and `get_params()`methods. The `set_params()`allows uses to adjust model hyperparmameters programmatically. Fore:

```python
from sklearn.ensemble import RandomForestClassifier

# Create a RandomForestClassifier model
model = RandomForestClassifier()

# set hyperparameters
model.set_params(n_estimators=100, max_depth=5, random_state=1)

# check the updated parameters
model.get_params()
```

## Coverage is a signal, not a target

There is a well-known saying to the effect that whatever you measure is what will be maximized. That is Goodhart’s law. People will tend to game the measure, doing unproductive things simply to maximise the number they are being rewarded for. Can understand why some organisations get a bit too excited aobut test coverage.

| **Concept**          | **The "Incentive"** | **The "Gaming" Behavior**                   | **Result**                                |
| -------------------- | ------------------- | ------------------------------------------- | ----------------------------------------- |
| **Goodhart's Law**   | High Test Coverage  | Writing meaningless tests just to hit the % | False sense of security; brittle code.    |
| **Cobra Effect**     | Bug Bounties        | Creating bugs to "fix" them later           | More bugs; wasted budget.                 |
| **Measurement Bias** | High Lines of Code  | Refusing to refactor or simplify            | Unmaintainable, complex "spaghetti" code. |

#### Using bebugging to discover feeble tests -- 

Start that wile the code coverage tool can tell us which code has been touched, it cannot tell us whethe the logic we are testing is meaningfully valiated -- 

- `Breadth`-- How many lines of code did the test run -- this is the metric that most tools count.
- `Depth`-- To quote -- Did U meaningfully touch this line of code -- 
  - Fore, if write a test that calls the `Add`but doesn’t check if the return value is correct, or just check that it doesn’t crash.

And when U take over someone else’s codebase, or fixing bugs in an old system, often can’t trust the exsiting tests, the article proposes two coping stategies -- 

1. Passive strategy -- deep code reading -- Don’t just look at whether the test passes, read the test code line by line, and ask youself what the hell tested here.
2. Core concepts -- feeble tests -- Tests that override code but are not adequately validted.
3. Bebugging -- Deliberately plant known bugs in the software and don’t tell the testers, if the test find these bugs, the test is valid, if not, it means that the test coverage is insufficent.

#### Automated Mutation testing

A mutation tester does automatically what we’ve just been doing manually, inserting bugs into the program, but it does  this in a very systematic way -- *Mutation testing* -- explaining in detail how it works, analysis of results, and limitations -- The mutation tester automates the process of manually changing the code to see if the test is hanging mentioned -- it is not random changes, but systeatic -- 

1. parse -- parse the code int a syntax tree, means that the tool can read the code structure, knowing where the assignment statement is and where the conditional judgement is.
2. Mutate -- Modify the logic based on the syntax structure.

##### Hunt the mutants

The workflow of the tool is intuitive, its purpose is to see if your test can kill these variants -- 

- Generate the mutation -- modify a line of code
- Run the test
- Test fails -- Good result -- indicate that your tests caught this bug -- the term is called Mutant killed -- this proves that thisl ine of code is efficientively overritten by the test
- No test fails -- bad result -- Means that the code logic has been chnaged, but the test still passed, -- the term is called Mutant survivied.

After tool runs, will be given a report of the chnges (diffs) that changed the code without causing the test to fail.

- Beef up feeble test -- if the variant modifies import logic and the test does not work -- your test is too fragile and must be supplemented with test cases
- Remove the code -- If the code is changed or even deleted, the test does not respond, and the system is running normally, sometimes it means that the code is simply redundant -- can be deleted directly.

Limitation -- False Positives -- Variation test is very reiorous and can sometimes be too nitpicking, reporting changes that don’t actually the program’s behavior -- called false positives. Fore for the `Println`

#### Finding a bug with mutation testing

Write a func and see if mutation testing can discover any interesting bugs or feeble tests -- keep it simple for demonstration purposes.

```go
func TestIsEven_IsTrueForEvenNumber(t *testing.T) {
	t.Parallel()
	for i := 0; i < 100; i += 2 {
		t.Run(strconv.Itoa(i), func(t *testing.T) {
			if !even.IsEven(i) {
				t.Error(false)
			}
		})
	}
}

func TestIsEven_IsFalseForOddNumber(t *testing.T) {
	t.Parallel()
	for i := 1; i < 100; i += 2 {
		t.Run(strconv.Itoa(i), func(t *testing.T) {
			if even.IsEven(i) {
				t.Error(true)
			}
		})
	}
}
```

##### Runining `go-mutesting`-- 

For this example, will use the `go-mutesting`tool, which can install by running this command -- 

```sh
go install github.com/zimmski/go-mutesting/cmd/go-mutesting@latest # zimmski's library
```

And one very important caveat before start -- Make backup of your entire project, including the `.git`directory, before running `go-mutesting`.