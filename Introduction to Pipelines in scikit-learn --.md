# Introduction to Pipelines in scikit-learn -- 

In ML, mangaing the workflow of data preprocessing and model trainign can become a complex, especially when multiple steps are involved. The `Pipeline()`in scikit-learn offers a powerful solution to streamline this process. A pipeline in scikit-learn is essentially a sequence of steps that are executed in order.

- Sequential execution -- Each step is performed in the order defined, ensuring that transformations are applied consistently across both training and test datasets.
- Code simplification -- help condense multiple lines of code into a single object, making the code base cleaner and esier to manage.
- Consistency -- By encapsulating all preprocessing steps into one object, you ensure that the same transformations are applied during both the training and prediction phases, minimizing the risk of data leakage.
- Easier hyperparameter tuning -- Pipelines integers seamlessly with scikit-learn’s hyperparameter tools, such as `GridSearchCV`, enabling users to optimize parameters for both preprocessing steps and model training all at once.
- Modularity -- Pipelines promote modularity by allowing different stages of processing to be encapsulating as reusable components. -- this makes it easier to experiment with various preprocessing techniques or models without rewriting large portions of code.

```python
pipeline = Pipeline(
	[('name of step', transformer),
      ('name of step', transformer),...
      ('name of step', estimator)
    ]
)
```

It should be noted that the final step in the pipeline, optionally, can be an estimator such as `LogisticRegression()`fore.

```python
from sklearn.pipeline import Pipeline
from sklearn.impute import SimpleImputer
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split

X = transformed_df.iloc[:, :-1] # all columns except last
y = transformed_df.iloc[:, -1] # last column

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=2024
)
```

Then create DataFrame with the transformed data -- to preserve column names -- like:

```python
pipeline = Pipeline([
    ('imputer', SimpleImputer(strategy='mean')), #handling missing values
    ('scaler', StandardScaler()), # scaler the features
])
pipeline.fit(X_train, y_train)

X_train_transformed = pipeline.transform(X_train)
x_test_transformed = pipeline.transform(X_test)

# then create DataFrame with transformed
X_train_transformed = pd.DataFrame(X_train_transformed, 
                                   columns=X_train.columns,
                                   index=X_train.index)
x_test_transformed = pd.DataFrame(x_test_transformed, 
                                  columns=X_test.columns,
                                  index=X_test.index)
```

Will also notice that prior to applying our pipeline transformations -- added a step to split our dataset into training and testing datast using scikit-learn’s `train_test_split()`function. This may seem trivial at first.

#### Visualizing pipelines

scikit-learn also allows U to visualize your pipeline using `set_config()`and `display`just like:

```python
from sklearn import set_config
set_config(display='diagram')
pipeline
```

Pipelines support indexing, fore, `pipeline[1]`returns the second estimator in the pipeline, and `pipeline[:-1]`returns a `Pipeline`object containing all but the last estimator. Can also access the estimators via the `steps`attriute. which is a list of name/estimator pairs, or via the `named_steps`dictionary attribute.

Fore have to applying the appropriate transformation to each column, can use the `ColumnTransformer`like:

```python
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import OneHotEncoder

num_attribs = ["longitude", "latitude", "housing_median_age", "total_rooms",
               "total_bedrooms", "population", "households", "median_income"]
cat_attribs = ["ocean_proximity"]

cat_pipeline = make_pipeline(
    SimpleImputer(strategy="most_frequent"),
    OneHotEncoder(handle_unknown="ignore"))

preprocessing = ColumnTransformer([
    ("num", num_pipeline, num_attribs),
    ("cat", cat_pipeline, cat_attribs),
])
```

First, import the `ColumnTransformer`class, then define the list of numerical and categorical column names and construct a simple pipeline for categorical attributes.

Since listing all the column names is not very convenient, Scikit-Learn provides a `make_column_selector()`function U can use to automatically select all the features of a given type, such as numerical or categorical. Can pass this selector function to the `ColumnTransformer`instead of column names or indices. Moreover,  if don’t care about naming the transformers, just like `make_pipeline()`does -- fore -- 

```python
from sklearn.compose import make_column_selector, make_column_transformer

preprocessing = make_column_transformer(
    (num_pipeline, make_column_selector(dtype_include=np.number)),
    (cat_pipeline, make_column_selector(dtype_include=object)),
)
```

### What is `GridSearchCV`

`GridSearchCV`does 3 things -- 

1. Iterate through all the hyperparameter combinations you give.
2. Corss-valiation for each combination
3. The best combination is selected based on the scoring metrics.

U can set hyperparameters on models or transformers at any depth in your pipeline -- Scikit-Learn accesses the hyperparameters of nested objects via `__`. fore:

```python
preprocessing__geo__n_clusters
```

| part          | Meaning                                         |
| ------------- | ----------------------------------------------- |
| preprocessing | A step called preprocessing  in a pipeline      |
| geo           | A  transformer called geo  in ColumnTransformer |
| n_clusters    | geo is a hyperparameter of this transformer     |

Fore, Scikit-Learn automatically finds the corresponding object along the path of the `Pipeline`-> `ColumnTransformer`-> Transformer.

```python
full_pipeline = Pipeline([
    ("preprocessing", preprocessing),
    ("random_forest", RandomForestRegressor(random_state=42)),
])
```

Pipeline for this has two steps -- 

1. `preprocessing`-- it’s a `ColumnTransformer`
2. `random_forest`-- it’s a `RandomForestRegressor`

```python
grid_search = GridSearchCV(full_pipeline, param_grid, cv=3,
                           scoring='neg_root_mean_squared_error')
grid_search.fit(housing, housing_labels)
```

- `cv=3`-- 3-fold cross-validation
- `scoring='neg_root_mean_squared_error'`use RMSE as an evaluation metric -- smaller is better.
- `fit()`-- automates training and evaluation for all combinations.

```python
from sklearn.model_selection import GridSearchCV
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics.pairwise import rbf_kernel

full_pipeline = Pipeline([
    ("preprocessing", preprocessing),
    ("random_forest", RandomForestRegressor(random_state=42)),
])
param_grid = [
    {'preprocessing__geo__n_clusters': [5, 8, 10],
     'random_forest__max_features': [4, 6, 8]},
    {'preprocessing__geo__n_clusters': [10, 15],
     'random_forest__max_features': [6, 8, 10]},
]
grid_search = GridSearchCV(full_pipeline, param_grid, cv=3,
                           scoring='neg_root_mean_squared_error')
grid_search.fit(housing, housing_labels)
```

Notice that you can refer to any hyperparameters of any estimator in pipeline, even if this estimator is nested deep inside several pipelines and columns transformers. Fore, when Scikit-learn sees `preprocess__geo__n_clusters`it splits this string at the double underscores.

1. First starts by looking for step called *preprocessing* throughout the pipeline and finds *the column converter called preporcessing*.
2. Then looks inside the column transformer for a transformed called `geo`and find the `ClusterSimiarity`transormer that we use for the latitude and longitude property.

#### Randomized Search

The grid search approach is fine when U are exploring relatively few combinations, like in the previous exmaple, But `RandomizedSearchCV`is often preferable, especially when the hyperparameter search space is large. This class can be used in much the same way as the `GridSearchCV`class. But instead of trying out all possible combinations it evaluates a fixed number of combinations, selecting a random value for each hyperparameter at every iteration.

- *Grid Search* is a brute-force method, U give it a list of settings, and it tries every single possible combination.
- *Randomized Search* -- Allows U set a range of options, and instead of trying everying, it throws darts at the board. Picks a random combination of setting for a specific number of tries that you define.

Benefit 1-- It finds better sweet spots for continuous numbers -- Imagine U have a setting that can be any number between 1 and 100.

Benefit 2 -- It dosn’t waste time on useless settings - Sometimes, a setting doesn’t actually affect the model’s performance at all.

Benefit 3 - It prevents *Combinatoral Explosion* Fore:

```python
from sklearn.model_selection import RandomizedSearchCV
from scipy.stats import randint

param_distribs = {'preprocessing__geo__n_clusters': randint(low=3, high=50),
                  'random_forest__max_features': randint(low=2, high=20)}

rnd_search = RandomizedSearchCV(
    full_pipeline, param_distributions=param_distribs, n_iter=10, cv=3,
    scoring='neg_root_mean_squared_error', random_state=42)

rnd_search.fit(housing, housing_labels)
```

## Adding a query timeout

Now that we’ve got some code that mimics along-running query, enforce a timeout so tha the SQL query is automatically canceled if it doesn’t coplete within 3 seconds. Fore -- 

1. Using the `context.WithTimeout()`func to create a `context.Context`instance with a 3s timeout deadline.
2. Execute the SQL query using the `QueryRowContext()`method, passing the `context.Context`instance as a parameter.

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

- `defer cancel()`line is necessary cuz it ensures that the resources associated with our context will always be released before the `Get()`method returns, thereby preventing a memory leak.
- The timeout countdown begins from the moment that the context is created using `context.WithTimeout()`any time spent executing code between creating context and calling `QueryRowContext()`will count towards the timeout.

how dbs timeouts can occur not only during PostgreSQL query execution in Go app development, but also in other areas, here is the -- It’s important to point out that it’s entirely possible that a deadline can be triggered before a PSQL query officially starts.

Also, talked about `sql. The DB`connection pool is configured to allow up to 25 concurrent connections. If all 25 connections are in use, then any additional queries will be sent to `sql`. `The DB`is placed in a queue until a connection is available -- in this case -- or anything that causes delay -- the timeout is most likely to be reached before an idle dbs connection is obtained. If happens, `QueryRowContext()`will return a `context.DeadLineExceeded`error.

In a similar vein, it’s also possible that the timeout deadline will be hit later on when the data returned from the query is being processed with `Scan()`-- if this happens the `Scan()`will also return a `context.DeadLineExceed`error.

#### Updating our dbs model

Quickly update our dbs model to use a 3-s timeout deadline for all our operations. While we are at it, remove the `pg_sleep(8)`clause from the `Get()`method too.

```go
func (m MovieModel) Delete(id int64) error {
	if id == 0 {
		return ErrRecordNotFound
	}

	query := `
		DELETE FROM movies
		WHERE id = $1`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	result, err := m.DB.ExecContext(ctx, query, id)
	if err != nil {
		return err
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return err
	}

	if rowsAffected == 0 {
		return ErrRecordNotFound
	}

	return nil
}
```

### Misunderstanding Go contexts

Sometimes misunderstand the `context.Context`type despite it being one of the key concepts of the language and a foundation of concurent code in Go.

- A `time.Duration`from now
- A `time.Time`

Fore, consider an app that receives flight positions froma radar every 4 seconds - fore:

```go
type Publisher interface {
    Publish(ctx context.Context, position flight.Position) error
}

type PublishHandler struct {
    pub publisher
}

func (h publishHandler) publishPosition(position flight.Position) error {
    ctx, cancel := context.WithTimeout(context.Background(), 4*time.Second)
    defer cancel()
    return h.pub.Publish(ctx, position)
}
```

Internally, `context.WithTimeout`creates a goroutine that will be retinaedin memory for 4 seconds or until `cancel`is called. Therefore, calling `cancel()`as a `defer()`means that when exit the parent func, the context will be caneled.

#### Cancellation signals

Another use case for Go context is to carry a cancellation signal -- imagine that want to create an app that calls `CreateFileWatcher`within another goroutine. This func creates a specific file watcher that keeps reading from a file and catches updates.

Finally, when `main`returns, want things to be handled gracefully by closing this file descriptor.

##### Context Values

The last use for Go Context is to carry a key-value list -- before understanding the rationale behind it -- first see how to use it -- A context conveying values can be created this way -- fore:

```go
ctx := context.WithValue(parentCtx, "key", "value")
```

For this like `context.WithTimeout, context.WithDeadline`and `WithCancel`, -- `context.WithValue`is created from a parent context -- in this case, create a new `ctx`context containing the same characteristics as `parentCtx`but also conveying a key and a value.

```go
ctx := context.WithValue(context.Background(), "key", "value")
fmt.Println(ctx.Value("key")) // value output
```

##### Catching context Cancellation

The `context.Context`type exports a `Done`method that returns a receive-only notification channel `<-chan struct{}`-- this is closed when the work associated with the context should be canceled.

- The `Done`related to a context created with `context.WithCancel`is closed when the `cancel()`is called.
- The `Done`realted to a context created with `context.WithDeadline`closed when the deadline has expired.

One thing to note is that the internal channel should be closed when a context is canceled has met a deadline, intead of when it receives a spcific value, because the closure of a channel is the only channel action that all the consumer goroutines will receive. This way, all the consumers will be notified once a context is canceled or a deadline is reached.

Furthermore, `context.Context`exports an `Err`method that returns `nil`if the `Done`channel isn’t yet closed. Otherwise, it returns a non-nil error explaining why the `Done`channel was closed, fore -- 

- A `context.Canceled`error if the channle was canceled.
- A `context.DeadLineExceeded`error if the context’s deadline passed.

```go
func handler(ctx context.Context, ch chan message) error  {
    for {
        select {
        case msg := <-ch:
            // Do sth
        case <-ctx.Done():
            return ctx.Err()
        }
    }
}
```

Create a `for`loop and use `select`with two cases -- receiving messages from `ch`or receiving a signal that the context is done and we have to stop our job.