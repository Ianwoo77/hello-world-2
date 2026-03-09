# Esitmators, Transformers 

Every estimator in scikit-learn, whether a model or a transformer, follows a simple and intuitive interface -- `fit()`and `predict()`. Fore, `LinearRegression()`-- Calling `fit()`with training data allows the model to learn the optimal coefficients for predicting outcomes -- Afterward, `predict()`can be used on new data to generate predictions.

```python
from sklearn.linear_model import LinearRegression

X = np.array([[1], [2], [3], [4], [5]])
y = np.array([1, 2, 3, 3.5, 5])

model = LinearRegression()
model.fit(X, y)
x_new = np.array([[6], [7]])
y_new = model.predict(x_new)
print(y_new)
```

When to use `fit_predict()`-- usually comes down to whether U are doing *Supervised learning* or *Unsupervised learning*.

##### Using `fit()`and `pridct()`separately -- 

This is the std workflow for *supervised learning* -- Split your data into a training set and a testing set to see how well your model generalizes. For `fit()`, just strudies the rels between features, and `predict()`learned to new, unseen data to generate a prediction. Cuz U never want your model to see the test data during the training phase.

##### Using `fit_predict()`

Alomost exclusively used in *Unsupervised learning*, Specifially for *Clustering* or *Outliear Detection*. Fore, it fits the model to the data and immediately returns the cluster labels for those same data points.

```python
from sklearn.cluster import KMeans

X = np.array([[1], [2], [3], [4], [5]])
kmeans = KMeans(n_clusters=2, n_init='auto') # explicitly set n_init
labels = kmeans.fit_predict(X)
print(labels)
```

#### Transformers and the `transform()`

*Transformers* are tools that modify data by applying transformations such as scaling, normalization, or encoding to prepare it for modeling. Each tansformer follows a consistent interface, using the `fit()`to learn any necessary parameters from the data and the `transform()`method to apply those transformations.

```python
from sklearn.preprocessing import StandardScaler

X = np.array([[1, 2], [3, 4], [5, 6]])
scaler = StandardScaler()
scaler.fit(X)
X_scaled = scaler.transform(X)
print(X_scaled)
```

And another common shortcut -- `fit_transform()`, allows users to perform both steps in one command, making preprocessing workflows more efficient. This is where most -- trip up -- should only use `fit_transform()`on your *training data* and for your *test data*, must only use `transform()`.

And the test set is supposed to represent *future* unseen data, if U re-calculte the mean using the test data, you are leaking information from the future into your process.

#### Handling custom estimators and transformers

scikit-learn’s API is designed to be extensible, allowing developers to create custom estimators and transformers that integrate seamlessly into existing workflows. By just subclasing `BestEstimator`and `mixin`classes, can implement custom ML algorithms or data transformations. Each custom estimator should follow the scikit-learn interface by implementing the `fit()`and `transform()`or `fit()`and `predict()`methods. Will cover essential elements such as parameter validation using `check_is_fitted()`, hyperparameter management, and integration custom objects into pipeline in various through it.

##### Pipelines and workflow automation -- 

Traditional ML workflows are often seen as a linear sequence -- *Data acquisition* -> *Feature engineering* -> *Model trainging* -> *Offline evaluation* -> *Development*

But in production, this must evolve into a cirular pattern -- 

- Monitoring -- Observe how the model performs on real-time data to prevent model degradition
- Continuous Training -- Automatically retain the model based on new data.
- CI/CD -- Ensure that code and models can be integrated and released securely and quickly.

The essence of a pipeline is to encapsulate multiple discreate steps into a single object.

- Structured -- Enforces the correct sequence of steps to avoid making predictions before transforming data.
- Consistent -- Ensure that every preprocessing step performed on the training set is applied to the test set in the exact same way.
- Atomicity -- can perform `fit(), predict()`and *Cross-validation* entire pipeline as if you were working with a single model.

MLOps-- refers to the practice of integrating ML workflows into the integer life cycle of software development and operations. It focuses on automating the process of developing, testing, deploying, and maintaining ML models.

1. Bridge the gap between data science.
2. It improves collaboration since teams must think holistically about how models are utilized from various vantage points.
3. It speeds up model deployment by creating an ecosystem that automates pipeline tasks and maintain a framework for easy reproducibility across projects.
4. Enhances model performance monitoring, observability, and expanability to address issues such as model drift or technical debt.

Scikit-learn supports MLOps workflows with the following tools -- 

- `Pipeline()`-- Used to automate preprocessing and modeling steps.
- `GridSearchCV()`-- Used for hyperparameter optimization.
- Model persistence libraries -- used to save and deploy models

Additionally, scikit-learn’s compability with other MLOps platforms, such as *MLflow* or *Kubeflow*.

```python
strat_train_set, strat_test_set = train_test_split(
    housing, test_size=0.2, stratify=housing["income_cat"], random_state=42)
```

### Visualizing Geographical Data

```python
housing.plot(kind="scatter", x="longitude", y="latitude", grid=True, alpha=0.2)
plt.show()
```

#### Looking for Correlations-- 

Since the dataset is not too large, you can easily compute the *standard correlation cofficient* between every pair of attributes using the `corr()`method -- `corr_matrix = housing.corr()`.

```python
corr_matrix = housing.corr(numeric_only=True)
corr_matrix['median_house_value'].sort_values(ascending=False)
```

And the correlation coefficient ranges from -1 to 1. 1 means that there is a strong positive correlation -- fore, the median house value tends to go up when the median income goes up. When the coefficient is close to -1, it means that there is a strong negative correlation.

Using the Pandas `scatter_matrix()`function -- which plots every numerical attribute against every other numerical attribute.

```python
from pandas.plotting import scatter_matrix

attributes = ["median_house_value", "median_income", "total_rooms",
              "housing_median_age"]
scatter_matrix(housing[attributes], figsize=(12, 8))
# save_fig("scatter_matrix_plot")  # extra code
plt.show()
```

For the main diagonal would be full of straight lines if Pandas plotted variable against itself, which would not be very useful. So instead, the pandas displays a histogram of each attribute.

```python
housing.plot(kind="scatter", x="median_income", y="median_house_value",
             alpha=0.1, grid=True)
plt.show()
```

This diagram reveals several points -- The correlation is really strong, can clearly see the uptrend and the dot cloud is not too scattered. Fore -- 

- Horizontal line -- The diagram shows an anomaly set of specific numeric points.
- Data quirks -- It refers to the unnatural features of data caused by human procesing or system errors.

### Preparing the Data for ML algs

It’s time to prepare the data for your ML algs. Instead of doing this manually, should write functions for this purpose, for several good reasons -- 

- This will allow U to reproduce these transformations easily on any dataset.
- Will gradually build a library of transformation functions that U can reuse in future projects.

#### Clean the data

Most ML algorithms cannot work with missing features.

1. Get rid of the corresonding districts
2. Get rid of the whole attribute
3. Set the missing values to some value -- called *imputation*.

Instead of the preceding, fore, `dropna()`..., You will use a handy Scikit-learn class -- `SimpleImputer`-- the benefit is that it will store the median value of each feature -- this will make it possible to impute missing values not only on the training but also on the validation set, the test set, and any new data fed to the model.

```python
from sklearn.impute import SimpleImputer

imputer = SimpleImputer(strategy="median")
housing_num = housing.select_dtypes(include=[np.number]) # select data with only numerical attr
imputer.fit(housing_num)
```

For this, the `imputer`has simply computed the median of each attribute and stored the result in its `statistics_`instance variable. The `imputer`for now, only the `total_bedrooms`had missing values, but U cannot be sure that  there won’t be any missing values in new data after the system goes live.

For now, can use this *trained* `imputer`to transform the training set by replacing missing values with the learned medians -- just like:

```python
X = imputer.transform(housing_num)
```

And, missing values can also be replaced with the `mean`, `most_frequent`or with a constant using:

```python
X = imputer.transform(strategy="contant", fill_value="...")
```

##### Estimators -- 

- Def -- any object that can learn certain parameters from data is called an estimator.
- Core method -- `fit(X, y)`-- All learning processes are `fit()`done by calling. Unsupervised learning only needs to pass in features `X`, while supervised learning passes in features `X`and labels `y`.
- Hyperparameter management: Parameters that are not determined by data but are set by people, are called hyperparameters, in Scikit-learn, hyperparameters must be passed in via a ctor at instantiation `model=SimpleImputer(strategy="mean")`, not `fit()`

##### Transformers -- 

- Def -- An estimator with ability to modify/transform data.
- `transform(X)`-- It applies the rules learned in the `fit()`stage to the data `X`, returning the new data after transformation.

##### Predictors

- Core method -- `predict(X,y)`-- Enter the new data and return the forecast results.
- `score(X, y)`-- Built-in quick evaluation methods to measure the model’s performance on the test set.

Insepection -- Scikit-learn is designed to be transparent, making it easy for users to see what the model inputs and what the model has learned, it has a strict and clear naming convention.

- View user-entered hyperparameters -- Accessed directly as exposed instance variables without suffixes -- Fore, `imputer.strategy`-- the `mean`set when initialized it will be returned.

- Look at the parameters that the model learns from the data -- all learning parameters must end with an underscore.

  Fore, the weight coefficient learned by the linear regression model is called, `model.coef_`and the intercept is called `model.intercept_`.

##### Composition -- 

ML is usually not a single step, but a pipeline -- filling in missing values -> data standardization -> feature dimensionality reduction -> model training. You can package multiple transformers and the *Last Predictor* into one `Pipeline`. Behaves like an ordinary predicitor. Scikit-learn provides reasonble default values for most parameters, making it easy to quickly create a baseline working system.

### Fetching a Movie

Move on to the code for fetching and displaying the data for a specific movie -- 

```go
func (m MovieModel) Get(id int64) (*Movie, error) {
	if id == 0 {
		return nil, ErrRecordNotFound
	}

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	query := `
		SELECT  id, created_at, title, year, runtime, genres, version
		FROM movies
		WHERE id = $1`

	var movie Movie

	err := m.DB.QueryRowContext(ctx, query, id).Scan(
		&movie.ID,
		&movie.CreatedAt,
		&movie.Title,
		&movie.Year,
		&movie.Runtime,
		pq.Array(&movie.Genres),
		&movie.Version,
	)

	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, ErrRecordNotFound
		}
		return nil, err
	}

	return &movie, nil
}
```

#### Updating the API handler -- 

The next ting need to do is update our `showMovieHandler`so that it calls the `Get()`method just made.

```go
func (app *application) showMovieHandler(w http.ResponseWriter, r *http.Request) {
    id, err := app.readIDParam(r)
    if err != nil {
        app.notFoundResponse(w, r)
        return
    }
    
    // Call the `Get()` method to fetch the data for a specific movie, also need to use the 
    // `errors.Is()` to check if it returns a `data.ErrRecordNotFound` error, in which case 
    // send a 404 Not Found response to the client.
    movie, err := app.models.Movies.Get(id)
    if err != nil {
        switch {
        case errors.Is(err, data.ErrRecordNotFound):
            app.notFoundResponse(w, r)
        default:
            app.serverErrResponse(w, r, err)
        }
        return
    }
    // writeJSON...
}
```

```sh
curl -i localhost:4000/v1/movies/2 # -i for HTTP-header info
```

Why not use an unsigned integer for the movie ID -- at the start of the `Get()`-- have the following code -- 

```go
func (m MovieModel) Get(id int64) (*Movie, error) {
    if id < 1 {
        return nil, ErrRecordNotFound
    }
}
```

Why not use unsigned `unit64`type to store the ID in the Go code -- 

1. PSQL doesn’t have unsigned integers
2. Also, Go’s `database/sql`package doesn’t actually support any integer values greater then .. 

#### Updating a Movie

`PUT /v1/movies/:id`-- `updateMovieHandler()`-- Update the details of a specific movie. We will set up the endpoint so that a client can edit the `title, year, runtime`and `genres`values for a movie.