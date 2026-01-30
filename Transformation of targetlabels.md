# Transformation of target/labels

Explains how to handle the transformation of target values in machine learing regression, and how to simplify this process with tools provided by Scikit-learn. Usually we only focus on the preprocessing of input features, but sometimes the target value -- 

##### Why Transform Target Value --

Many ML alg, especially linear regression, assuming that data obeys a normal distribution -- if your target value distribution is heavy tail, this extreme value can seriously inference with model training.

Transformaiton method -- Usually take the target value logarithm and compress it into a shape closer to the normal distribution -- Consequences and problems -- If U train your model using log(price), then the results predicted by the model are also log(price). So -- 

- Question -- What the business side needs is the real *house price* not the logarithm of the house price -- 
- Solution -- have to perform an inverse transform on the prediction result, such as Expontential.

##### Method 1 -- Manuall Way

Shows how to manually complete the entire process of transform -> training -> prediction -> inverse transformation. For the code, just like:

```python
from sklearn.linear_model import LinearRegression

# create a normalizer to change the target to distribution with a mean 0 and variance of 1
target_scaler = StandardScaler()

# transform target value
# cuz, fit_transorm() to turn it into a DataFrame 2D
# current value is no longer the real house price, but standardized value
scaled_labels = target_scaler.fit_transform(housing_labels.to_frame())

# the model learns the relationship between stardardized price and income
model = LinearRegression()
model.fit(housing[["median_income"]], scaled_labels)

some_new_data = housing[["median_income"]].iloc[:5]  # pretend this is new data

# model.predict() -- the calculation is a std unit
# this new values are still in the normazlied space, are not understood by the person.
scaled_predictions = model.predict(some_new_data)

# pridication -- Auto inverse Transformations
# These are still in the normazlied space and are not understood by the average person
predictions = target_scaler.inverse_transform(scaled_predictions)
```

- `fit_transform`-- `inverse_transform`, Manually method, fit_transform label yourself, predict, and then yourself `inverse_transform`.
- Recommended practice - Use `TransfomedTargetRegressor`-- it makes the code cleaner, prevents you from forgetting to inverse transformations, and fits perfectly into Scikit-Learn’s pipeline mechanics.

Cons -- The code is cumbersome, it’s easy to forget about inverse transformations-- and it’s cumbersome to handle in cross-validation or pipelines.

| **Steps**            | **Code operations**                         | **Data status**                                              |
| -------------------- | ------------------------------------------- | ------------------------------------------------------------ |
| **Step 1: Training** | `model.fit(X, scaled_y)`                    | The model learns how to predict "scaled home prices          |
| **Step 2: Forecast** | `scaled_predictions = model.predict(X_new)` | **(The sentence you asked) gets** the scaled prediction result |
| **Step 3: Restore**  | `target_scaler.inverse_transform(...)`      | Turn those weird decimals back into the real dollar unit price |

#### `TransformedTargetRegressor`

This is an advanced solutino offered by Scikit-learn - `TransformedTargetRegressor`is a wrapper that packages the regression model and the target transformer together and automatcially handles the intermediate transformation logic.

Code flow analysis -- 

1. Build a composition model -- 

   ```python
   from sklearn.compose import TransformedTargetRegressor
   model = TransformedTargetRegressor(regressor=LinearRegression(),
                                      transformer=StandardScaler())
   ```

   - regressor -- The predictive model U actually want to use -- 
   - transformer -- The transformation U want to do the target value.

   Training -- auto-transform -- `model.fit(housing[["median_income"]], housing_labels)`

2. Traning - auto-transform -- `model.fit(housing[["median_income"]], housing_labels)`-

   - Key point -- Here U are passing in the original `housing_labels`
   - `TransofoedTargetRegressor`it will automatically call `transformer`to convert the labels first, and then train with the converted labels `regressor`

3. Prediction -- Auto inverse transformation -- 

   ```python
   predictions = model.predict(some_new_data)
   ```

What happens internally -- the internal linear regression model predicts  value and `TransformedTargetRegressor`then automatically calls the transformer `inverse_transform`to restore the result to.

#### Supplementary Tips -- 

Supplementary Tips -- `StandardScalar`, if your purpose is to do logarthmic transformations -- can like this. The core lesson of this section is that when the distirbution of target values is not ideal, transforming them can improve accuracy of the model.

- `fit_transform`label yourself, train, predict and then yourself `inverse_transform`.
- `TransfomedTargetRegressor`-- it makes the code cleaner, prevents you from forgetting do inverse transformations, and fits perfecty into Scikit-learn’s pipeline mechanics.

```python
import numpy as np
from sklearn.compose import TransformedTargetRegressor
from sklearn.linear_model import LinearRegression

# 使用 func 和 inverse_func 来指定对数和指数变换
model = TransformedTargetRegressor(
    regressor=LinearRegression(),
    func=np.log1p,      # 变换函数：log(y + 1)
    inverse_func=np.expm1 # 逆变换函数：exp(y) - 1
)

model.fit(X_train, y_train) # 自动做 log
preds = model.predict(X_test) # 自动做 exp，返回真实值
```

This works fine, but a simpler option is to use a `TransformedTargetRegressor`.  We just need to construct it, giving it the regression model and the label transformer, then fit it on the training set, using the original unscaled labels. It will automatically use the `transformer`to scale the labels and train the regression model on the resulting scaled lables, Just like we did prevously. Then when we wanto make prediction, it will call regression model’s `predict()`method and use the scalar’s `inverse_transform()`method to produce prediction.

```python
from sklearn.compose import TransformedTargetRegressor

model = TransformedTargetRegressor(LinearRegression(),
                                   transformer=StandardScaler())
model.fit(housing[["median_income"]], housing_labels)
predictions = model.predict(some_new_data)
```

##### Converage profiling with the `go`tool

`go test -cover`-- Not bad -- but it looks like some statements aren’t covered by any test. That might be okey.  This might be okay, but we’d like to know which statements aren’t covered, so we can check them. To get that information we need to generate a *coverage* profile.

`go test -ocverprofile = coverage.out`
`go tool cover -html = converge.out`.

This will open the default web browser with an HTML page showing the code high-lighted in different colours. Covered code is shown in green, while uncovered code is shown in red. Some source lines just aren’t relevant to test coverage, such as imports, function names, comments, and so on.

This text details how to use the toolchain into the Go language for code Coverage analysis -- Code coverage is an important measure of test quality, telling you what percentage of code is actually executed by test cases.

The Go toolchain makes it very easy to view coverage in 3 main steps - 

1. Quick test - `go test -cover`-- most basic comand, and it will output a percentage -- directly in the terminal. It gives U a qucik idea: 
2. `go test -coverprofile=coverage.out`-- for further analysis, we need to export the details execution data to a file.
3. `go tool cover -html=coverage.out`-- this is the most useful feature. It generates a temporary HTML page and opens in the browser.
   - Green -- The code has been covered by the test
   - Red -- The code is not being executed, which is where U need to focus your attention
   - gray -- Non-executable statements that are not counted in the statistics.

#### Core Philosophy: pragmatism vs Blind pursuit of 100% -- 

This text quotes the author of the Go programming language and conveys a very important engineering idea.

- Testing has a cost -- Test code is also code, requies maintance, and is also a kind of technical debt.
- The benefits from 0% to 80% are huage, but increasing from 90% to 100% often requires writing a lot of complex mocks or extreme boundary condition tests that often to generate equivalent vlaue.
- Not all `red`codes need to be fixed
- Coverage is a tool, not a goal -- high coverage doesn’t mean your code isn’t bug-free, it just helps U find blind spots.

##### Thchnical principle instrumention

How does Go know which line is running and which is not -- 

- When U run a test with a coverage flag, the Go compiler `operates`at the compile stage, inserts Counter code before and after line of your statement.
- Record Execution -- when the program runs, the corresonding counter increases with each block of code passed.

The core recommendation of this article is use `Go tool Cover`to find those uncovered and logically complex red code areas and write high-quality tests in a targted manner, rather than meaningles tests to make up 100% of the numbers.