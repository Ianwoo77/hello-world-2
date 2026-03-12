# `Normazlier()`-- details

A very important concept in ML data preprocessing -- normalization, which corresponds to `Normalizer()`classes in scikit-learn -- To give U thorough understanding -- break down in detail from 5 aspects -- core concepts, mathematcial formulas. In ML, usually deal with a matrix with rows representing Samples and columns representing Features.

The vat majority of preprocessing methods `StandardScaler, MinMaxScaler`are operated by column. Where `Normailzier()`is operated by row (landscape) -- it purpose to scale each individual sample so tha the vector length of what sample is equal to 1. Fore:

```python
from sklearn.preprocessing import Normalizer
import numpy as np

# 定义两个样本，包含三个特征
X = np.array([[1.0, -2.0,  3.0], 
              [3.0,  4.0,  0.0]])

# 1. 使用 L1 Normalization
normalizer_l1 = Normalizer(norm='l1')
X_l1 = normalizer_l1.transform(X)
print("L1 结果:\n", X_l1)
# 样本1绝对值和为6 -> [1/6, -2/6, 3/6]
# 样本2绝对值和为7 -> [3/7, 4/7, 0]

# 2. 使用 L2 Normalization (默认)
normalizer_l2 = Normalizer(norm='l2')
X_l2 = normalizer_l2.transform(X)
print("L2 结果:\n", X_l2)
# 样本1的L2范数为 sqrt(1+4+9) = 3.74
# 样本2的L2范数为 sqrt(9+16+0) = 5.0 -> [3/5, 4/5, 0]
```

##### Summary of Confusing points -- 

- `StandardScaler/MinMaxScaler`- Focus column -- it is used to eliminate the effects of diffreent feature dimensions.
- `Normalizer`-- Focus on rows it is used to eliminate the influentce of the overall magnitude (size) of a single sample itself, and only the proportional relationship of internal feature is retained.

```python
# epperimental feature requires loading
from sklearn.experimental import enable_iterative_imputer
from sklearn.impute import IterativeImputer

iterative_imputer = IterativeImputer()
iteraive_imputed_data = iterative_imputer.fit_transform(df)
iterative_imputed_df = pd.DataFrame(iteraive_imputed_data, columns=df.columns)
iterative_imputed_df

from sklearn.preprocessing import Normalizer

normalizer = Normalizer()
normalized_data = normalizer.fit_transform(iterative_imputed_df)
normalized_df = pd.DataFrame(
    normalized_data,
    columns = iterative_imputed_df.columns
)
normalized_df
```

If U want to prove to yourself that the code worked correctly, run this of code right after generating `normalized_df`.

```python
(normalized_df**2).sum(axis=1) # outout 1
```

Every row will sum to 1.0, confirming that every sample is now a unit vector on a multidimensional sphere. Each technique provides a different approach to data scaling -- but keep in mind that just like with missing values, not all requires data scaling -- Again, tree-based methods are decision trees and *Random forest work just* the raw data values for input feature.

- L2 regularization - Gives the sum of the squares of each feature of he sample to 1
- L1 regularization -- The sum of the absolute values of each feature in the sample is 1

##### It’s key role

If only care about the proportional relationship between features, not their absolute values, `Normalizer`comes in handy. For the comparation -- 

| **Characteristics**        | **StandardScaler**                                           | **Normalizer**                                               |
| -------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| **Direction of operation** | **Columns (features):** Calculate the mean and variance by column | **Rows (samples):** Calculate the norm by rows               |
| **Math Goals**             | Convert the feature to mean 0 with variance 1                | Change the vector length of each sample to 1                 |
| **Application scenarios**  | Most models (linear regression, logistic regression, SVM)    | Text classification, clustering, image processing (when angle/scale is important) |
| **Geometry is intuitive**  | Move and scale data distribution centers                     | Project all points onto the circumference/sphere             |

```python
from sklearn.preprocessing import Normalizer
import numpy as np

data = [[4, 1, 3], 
        [1, 1, 1]] # 第二个样本明显比第一个“小”

scaler = Normalizer(norm='l2')
print(scaler.fit_transform(data))

# 输出后的每个子列表（行），其平方和都等于 1
```

#### Encoding Categorical variables -- 

Categorical variables are a common feature in many datasets, representing discreate values such as categories, labels, or groups. Most ML algorithms require numerical input, making it essential to convert categorical data into a suitable format.

1. Scaler -- the *prepper* -- is a type of Transformer. Its job is to adjust the numerical range of your features so that one big number doesn’t overwhelm a small number. Fore `StandardScaler`, `MinMaxScaler`, use this for algs senstive to distance -- like KNN, SVM, or nn.
2. Encoder -- *translator* -- An Encoder translates categorical text into numbers so that a model can process -- `OneHotEncoder`, `OrdinalEncoder`, `LabelEncoder`-- Specifically used for the target variable the `y`value.
3. Estimator -- *Brain/tool* -- Is an object that can learn from the data. Usually use the term to reer to the `Models`that make predictions -- `Regressor`and `Classifier`.

| **Component** | **Method Used**            | **Purpose**                     | **Example**          |
| ------------- | -------------------------- | ------------------------------- | -------------------- |
| **Encoder**   | `.fit_transform()`         | Turn text into numbers          | `OneHotEncoder`      |
| **Scaler**    | `.fit_transform()`         | Normalize/Standardize numbers   | `StandardScaler`     |
| **Estimator** | `.fit()` then `.predict()` | Learn patterns and make guesses | `LogisticRegression` |

```python
np.random.seed(2024) # for reproducibility
categories = ["A", "B", "C", "D"]
categorical_data = pd.DataFrame(
    {
        "Department": np.random.choice(
            categories, size=20),
        "Position": np.random.choice(
            ["Junior", "Senior", "Manager"], size=20),
        "Location": np.random.choice(
            ["NY", "SF", "LA", "CHI"], size=20),
    }
)
```

As can see, choosing the appropriate approach to a stage in data preprocessing requires an understanding of not only what U are trying to accomplish with your model but also the implications of the techniques U choose, such as `OneHotEncoder()`, `LabelEncoder()`or `Columntransformer()`.

```python
from sklearn.preprocessing import OneHotEncoder

onehot_encoder = OneHotEncoder(sparse_output=False)
onehot_encoded_data = onehot_encoder.fit_transform(categorical_data)
onehot_encoded_df = pd.DataFrame(onehot_encoded_data, columns=onehot_encoder.get_feature_names_out())
onehot_encoded_df
```

For this, `OneHotEncoder()`transforms our dataset of categorical variables into a series of binary features, where each new feature represents one of our original feature’s categories. Keep in mind that a dataset containing many categorical features and/or numerous categories within features can result in `OneHotEncoder()`making extremely large, sparse datasets ones and zeros.

## Scikit-Learn’s transformers

Scikit-learn’s transformers have an `inverse_transform()`method, making it easy to compute the inverse of their transformations. Fore the following code shows how to scale the labels using a `StandardScaler`, then train a simple linear regression model on the resulting scaled labels and use it to make predictions on some new data.

```python
strat_train_set, strat_test_set = train_test_split(
    housing, test_size=0.2, stratify=housing["income_cat"], random_state=42)
housing = strat_train_set.drop("median_house_value", axis=1)
housing_labels = strat_train_set["median_house_value"].copy()
cat_encoder = OneHotEncoder(sparse_output=False)
housing_cat_1hot = cat_encoder.fit_transform(housing_cat)
housing_cat_1hot
```

Then introduces an advanced feature engineering tech for handling multimodal distributions - radial basis function *RBF* characterization -- In simle terms -- when your data has a special performance new some specific value -- peak - can tell the model in this way -- how close is this sample to that key point. It just breaks down a complex, nonlinear multimodal distribution into several local influence feature that are easier for models to understand.

Fore, if know the *median income* in an area, an predict the median house price in that area -- \

```python
from sklearn.linear_model import LinearRegression

# most data will fall [-3, 3]
target_scaler = StandardScaler()
scaled_labels = target_scaler.fit_transform(housing_labels.to_frame())

model = LinearRegression()
model.fit(housing[["median_income"]], scaled_labels)
some_new_data = housing[["median_income"]].iloc[:5]  # pretend this is new data

scaled_predictions = model.predict(some_new_data)
predictions = target_scaler.inverse_transform(scaled_predictions)
```

This code shows a very canonical process in ML -- Univariate linear regression with label scaling. In simple terms -- this code asks the model a question -- if know that the median income in an area, can predict the median house price in that area -- 

##### Train the model

```python
model = LinearRegression()
model.fit(housing[['median_income']], sclaed_labels)
```

It just tries to find the most appropriate `w`and `b`so that the difference between predicted value and the actual scaled house price is minimal.

##### Prediction & inverse transform

```python
scaled_predictions = model.predict(some_new_data)
predictions = target_scaler.inverse_transform(scaled_predictions)
```

- Prediction -- The model split out results that are also *scaled* small number
- `inverse_transform` - Turns these meanineless small numbers back into real units of the house price.

This works, But a simpler option is to use a `TransformedTargetRegressor`. Just need to construct it, giving it the regression model and the label transformer, then fit it on the training set, using the original unscaled labels. It will automatically use the transformer to scale the labels and train the regression model on the resulting scaled labels.

```python
from sklearn.compose import TransformedTargetRegressor

model = TransformedTargetRegressor(LinearRegression(),
                                   transformer=StandardScaler())
model.fit(housing[["median_income"]], housing_labels)
predictions = model.predict(some_new_data)
```

#### Custom Transformers

Will need to write your own for tasks such as custom transformations, cleanup operations, or combining secific attributes. It’s also often a good idea to transform features with heavy-taild distributions by replacing them with their logarithm - create a log-transformer and apply it to `population`feature like:

```python
from sklearn.preprocessing import FunctionTransformer

log_transformer = FunctionTransformer(np.log, inverse_func=np.exp)
log_pop = log_transformer.transform(housing[["population"]])
```

Note that the `inverse_func`arg is optinal, lets U specify an inverse transform function -- And your transformation function can take *hyperparameters as additional arguments* -- fore -- 

```python
rbf_transformer = FunctionTransformer(rbf_kernel,
                                      kw_args=dict(Y=[[35.]], gamma=0.1))
age_simil_35 = rbf_transformer.transform(housing[["housing_median_age"]])
```

For this there is no inverse function for the RBF kernel, since there are always two values at a given distance from a fixed point -- also note that `rbf_kernel()`does not treat the features separately.

- `Y=[[35.]]`-- this is the reference point
- Benefits -- encapsulation allows U to cram RBF logic directly int a `Pipeline`or `ColumnTransformer`for fully automated data preprocessing.

Also note that `rbf_kernel()`does not treat the feature separately, if pass it an array with two features, it wil measure the 2D distance to measure similarity.

```python
sf_coords = 37.7749, -122.41
sf_transformer = FunctionTransformer(rbf_kernel,
                                     kw_args=dict(Y=[sf_coords], gamma=0.1))
sf_simil = sf_transformer.transform(housing[["latitude", "longitude"]])
```

Custom transformers are also useful to combine features.

```python
ratio_transformer = FunctionTransformer(lambda X: X[:, [0]] / X[:, [1]])
ratio_transformer.transform(np.array([[1., 2.], [3., 4.]]))
```

While `FunctionTransformer`is fast, can only handle *fixed logic*, fore, simple logarithmic conversions or RBF calculations -- When need the model to evolve from the data -- like calculating the mean of the training set and applying it on the test set -- 

Fore, `Scikit-learn`relies on duck typing -- so this class does not have to inherit from any particular base class, all needs is 3 methods -- `fit()`, `transform`and `fit_transform()`, so just like:

```python
from sklearn.base import BaseEstimator, TransformerMixin
from sklearn.utils.validation import check_array, check_is_fitted

class StandardScalerClone(BaseEstimator, TransformerMixin):
    def __init__(self, with_mean=True):  # no *args or **kwargs!
        self.with_mean = with_mean

    def fit(self, X, y=None):  # y is required even though we don't use it
        X = check_array(X)  # checks that X is an array with finite float values
        self.mean_ = X.mean(axis=0)
        self.scale_ = X.std(axis=0)
        self.n_features_in_ = X.shape[1]  # every estimator stores this in fit()
        return self  # always return self!

    def transform(self, X):
        check_is_fitted(self)  # looks for learned attributes (with trailing _)
        X = check_array(X)
        assert self.n_features_in_ == X.shape[1]
        if self.with_mean:
            X = X - self.mean_
        return X / self.scale_
```

Here are a few things to note -- 

- `sklearn.utils.validation`contains several functions can use to validate the inputs. Will skip such tests in the rest.
- Require the `fit()`to have two args `X`and `y`-- which is why we need the `y=None`even though don’t need it.
- `self.n_features_in_`-- in the `fit()`-- ensure that the data passed to `transform()`or `predict()`has this number of features.
- `fit()`need to return `self`.

Also, a custom transformer can use other estimators in its implementaion. Fore the following code demonstrates custom transformers that uses a `KMean`cluster in the `fit()`to identify the main clusters i the training data, and then use the `rbf_kernel()`in the `transform()`method to measure how *similar* each sample is to each cluster center.

```python
from sklearn.cluster import KMeans # used as a tool for feature engineering

class ClusterSimilarity(BaseEstimator, TransformerMixin):
    def __init__(self, n_clusters=10, gamma=1.0, random_state=None):
        self.n_clusters = n_clusters
        self.gamma = gamma
        self.random_state = random_state

    def fit(self, X, y=None, sample_weight=None):
        self.kmeans_ = KMeans(self.n_clusters, n_init=10,
                              random_state=self.random_state)
        self.kmeans_.fit(X, sample_weight=sample_weight)
        return self  # always return self!

    def transform(self, X):
        return rbf_kernel(X, self.kmeans_.cluster_centers_, gamma=self.gamma)
    
    def get_feature_names_out(self, names=None):
        return [f"Cluster {i} similarity" for i in range(self.n_clusters)]
```

In this code, KMeans is a center point detector. It detects `K`the most representative central point at the `fit`stage, and then use this `K`point as a reference in the `tranform`stage. k-means is a clustering alg that locates clusters in the data. How many it searches for is controlled by the `n_clusters`hyperparameter. After training, the `cluster`center are avaiable via the `cluster_centers_`attriute.

### Null vlaues in JSON -- 

One special-case to be aware of is when the client explicitly supplies of a field in the JSON request with the value `null`-- in this case, our handler will ignore the field and treat it like it hasn’t been supplied.

#### Optimistic Concurrency Control

For the `updateMovieHandler()`-- there is a *race condition* if two clients try to update the same movie record at exactly the same time. Pretend that we two clients using our -- 

1. For one calls `app.models.Movies.Get()`to retreive a copy of a movie record
2. Bob’s goroutine calls `app.models.Movies.Get()`to retrive a copy of movie record
3. Alice’s goroutine changes the runtime to 97 minutes in ints copy of the movie record.
4. Bob’s goroutine updates the genres include *comedy* in its copy of the movie record.
5. Alice’s goroutine calls `app.models.Movie.Update()`with its copy of the movie record. The movie record is written to the dbs and the version number is incremented to N+1.
6. Bob’s goroutine calls `app.models.Movies.Update()`with its copy of the movie record.

##### Preventing the data race

There are a couple of options, but the simplest and cleanest approach in this case is to use a form of optimistic locking based on the `version`number in our movie record -- 

1. A and B’s gorotuines both call `app.models.Movies.Get()`to retrieve a copy of the movie record. Both of these records have the version number `N`.
2. A and B’s goroutines make ther respective changes to the movie record.
3. A and B’s goroutines call `app.models.Movies.Update()`with their copies of the movie record. But *the update is only executed* if the *version number in the dbs is still N*. If it has changed, then don’t execute the update and send the client an error message instead. This just means that the first update request that reaches our dbs will succeed, and whoever is making the second update will receive an error message.

```sql
UPDATE movies
SET title = $1, year = R2, runtime= $3, genres= $4, version = version+1
WHERE id = $5 and version = $6
RETURNING version
```

And if no matching record can be found, then this query will result in a `sql.ErrNoRows`error and we know that the ersion number has been changed.

#### Implementing optimistic locking

Start by creating a custom `ErrEditConflict`error that can return from our dbs model -- like:

```go
var (
    ErrEditConflict = errors.New("Edit conflict")
)
```

```go
func (m MovieModel) Update(movie *Movie) error {
	query := `
		UPDATE movies
		SET title = $1, year = $2, runtime = $3, genres = $4, version = version + 1
		WHERE id = $5 AND version = $6
		RETURNING version`

	args := []any{
		// ...
	}

	err := m.DB.QueryRowContext(ctx, query, args...).Scan(&movie.Version)
	if errors.Is(err, sql.ErrNoRows) {
		return ErrEditConflict
	}
	if err != nil {
		return err
	}
	return nil
}
```

Then just head to our `cmd/api/errors.go`file and create a new `editConflictResponse()`helper, want this to send a 409 *Conflict* response, along with a plain-English error message that explains the problem to the client.

```go
func (app *application) editConflictResponse(w http.ResponseWriter, r *http.Request) {
	message := "unable to update the record due to an edit conflict, please try again"
	app.errorResponse(w, r, http.StatusConflict, message)
}
```

Then as the final step, need to change our `updateMovieHandler`so that it checks for an `ErrEditConflict`error and calls the `editConflictResponse()`helper if necessary -- like so -The main part of the function is like:

```go
err = app.models.Movies.Update(movie)
if err != nil {
    switch {
        case errors.Is(err, data.ErrEditConflict):
        app.editConflictResponse(w, r)
        return
        default:
        // fallthrough to next error handling
        app.serverErrorResponse(w, r, err)
        return
    }
}
```

At this point, our `updateMovieHandler`should now be safe from the race condition that we’ve been talking about -- if two goroutines are executing the code at the same time, the first update will succeed, and the 2nd will fail cuz the `version`number in the dbs no longer matches the expected value.

##### Round-trip locking

One of the nice things about the optimitic locking pattern that we have used here is that U can extend it so the client passes the version number that they *expect in an *If-Not-Match* or *x-Expected-Version* header. In certain apps, this can be useful to help the client ensure they are not sending their update request based on *outdated* information.

#### Managing SQL Query Timeouts

But Go also provides context-aware variants of these two methods -- `ExecContext()`and `QueryRowContext()`-- These variants accept a `context.Context`instance as the first parameter which you can leverage to terminate running database queries.

This feaure can be useful when you have a SQL query that is taking longer to run than expected. When this happens, it suggests a problem -- either with that particular query or your database or application more generally - and U probably want to cancel the query, log an error for furhter investigation, and return a *500 internal Server error*.

##### Mimicking a long-running query -- 

To help demonstrates how this all works -- start by adapting our dbs model’s `Get()`method so that it mimics a long-running query. Specifically, update our SQL query to return `pg_sleep(8)`value, which will make PostgreSQL sleep 8 seconds before runing its result.

