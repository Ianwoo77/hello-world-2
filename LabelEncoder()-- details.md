# `LabelEncoder()`-- details

Assigns a unique integer to each category in a nominal feature -- while this method is straightforward and efficient.

```python
from sklearn.preprocessing import LabelEncoder
 
label_encoder = LabelEncoder()
label_encoded_df = pd.DataFrame()
for column in categorical_data.columns:
    label_encoded_df[f"{column}_encoded"] = (
        label_encoder.fit_transform(categorical_data[column])
    )
label_encoded_df
```

`LabelEncoder()`will assign arbitrary values to categorical features, and these values could be interpreted by ML alg as defining some measure of distance when -- in fact, they do not even though we used this approach on the original dataset from the previous example.

##### `ColumnTransformer()`-- 

And when working with datasets that contain both numerical and categorical features, the `ColumnTransformer`class allows for seamless application of different preprocessing techniques across different columns. This is particularly useful when want to apply one-hot encoding to categorical features while leaving numerical features unchanged. Wll create a new toy dataset that combines both quantitive and qualtitive features.

So when it comes to working with *mixed* datasets with numerical and categorical features, `ColumnTransformer`is one of the most powerful tools in `scikit-learn`.  It allows U to perform different transformation operations on different columns in parallel.

Before don’t have it, have to manually split the `DataFrame`-- process the numeric and categorical features separately, and then concatenate them back. This is not only cumbersome, but also prone to *data leakage* during data cross-validation.  `ColumnTransformer`solves this problem by allowing U to do it in one step -- 

- Category column : `One-Hot`encoding
- Numerical column -- `Standardized`.

```python
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import OneHotEncoder, StandardScaler

ct = ColumnTransformer(
    transformers=[
        ('step_name', transformer_object, [column_indices_or_names])
    ],
    remainder='passthrough' # 关键参数：决定未指定的列如何处理
)
```

Fore, the steps are as follows -- like:

```python
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import StandardScaler
from sklearn.preprocessing import OneHotEncoder

np.random.seed(2024)
mixed_data = pd.DataFrame(
    {
        "Age": np.random.randint(25, 65, size=20),
        "Salary": np.round(np.random.normal(60000, 15000, size=20), 2),
        "Experience": np.random.randint(1, 20, size=20),
        "Department": np.random.choice(["IT", "HR", "Sales", "Finance"], size=20),
        "Position": np.random.choice(["Junior", "Senior", "Manager"], size=20),
    }
)

# then initialize the ColumnTransformer
column_transformer = ColumnTransformer(
    transformers=[
        ('num',StandardScaler(), ['Age', 'Salary', 'Experience']),
        ('cat',OneHotEncoder(), ['Department', 'Position']),
    ],
    remainder='passthrough'
)

transformed_data = column_transformer.fit_transform(mixed_data)

# get feature names for transformed columns -- 
numeric_cols= ['Age_scaled', 'Salary_scaled', 'Experience_scaled']
categorical_cols = (
    # the core task of this line is to obtain the new column names genreated by one-hot encoding
    # name_transformer_ allows us to access the particular instance through `OneHotEncoder`
    # cuz OneHot turns one to fore 3, so 
    # using `.get_features_names_out()` to get all columns
    # fore, ['Department_Finance', 'Department_HR', ... 'Position_Senior'] returned
    column_transformer.named_transformers_['cat']
    .get_feature_names_out(['Department', 'Position'])
)

# Create transformed DF
transformed_df = pd.DataFrame(
    transformed_data,
    columns=numeric_cols + list(categorical_cols)
)

transformed_df
```

#### Introduction to Pipelines in scikit-learn -- 

In ML, managing the workflow of data preprocessing and model training can become complex. The `Pipeline`in scikit-learn offers a powerful solution to streamline this process.

A pipeline in scikit-learn is essentially a sequence of steps that are executed in order.

- Sequential execution
- Code simplification -- Help condense multiple lines of code into a single object
- Consistency -- encapsulting all preprocessing steps into one object.
- Easier hyperparamter tuning
- Modularity

```python
pipeline = Pipeline(
	[('name of step', transformer),...
      ('name of step', transformer),
      ('name of step', estimator)...
    ]
)
```

### K-means clustering -- 

*k*-means is a clustering algorithm that locates clusters in the data. And how many it searches is controlled by the `n_cluster`hyperparameter -- After training, the cluster centers are availble via the `cluster_centers_`attribute. When dealing with geographical location -- this is more efficient than directly entering row coordinates.

- `sample_weight=housing_labels`-- telling K-Means that the higher the house price, the greater the weight of the area when clustering. This means that clustering centers will be more inclined to shift towards areas with high housing prices.
- `gamma=1.0`-- RBF determines how quickly similarity *decreases* with distance.

```python
from sklearn.cluster import KMeans

class ClusterSimilarity(BaseEstimator, TransformerMixin):
    def __init__(self, n_clusters=10, gamma=1.0, random_state=None):
        self.n_clusters = n_clusters
        self.gamma = gamma
        self.random_state = random_state
```

Key parameters -- the importance of `random_state`-- `K-Means`is randomly initialized -- 

- If don’t set `random_state`-- the location of the clustering hub may be fine-tuned every time U run your code.
- For feature engineering, if the center changes, the meaning of the generated feature column will change, resulting the model results being unreproduible.

#### Transformation Pipelines

As can see, there are many data transformation steps that need to be executed in the right order. Scikit-learn provides the `Pipeline`class to help with such sequences of transformations -- here is a small pipeline for numerical attributes, whcih will first impute then scale the input features -- like:

```python
from sklearn.pipeline import Pipeline

num_pipeline = Pipeline([
    ('imputer', SimpleImputer(strategy="median")),
    ('standardize', StandardScaler()),
])
```

The `Pipeline`ctor takes a list of *name/estimator* pairs -- 2-tuples -- defining a sequence of steps. The names can be anything you like, as long as they are unique and dont’ contain `__`. They will be useful later, when we discuss hyperparamter tuning. The estimators must all be transformer, except for the last one, which can be anything, a transformer, a predictor, or any other type of estimator.

- Simplificy -- only need to call `fit()`or `predict()`once, and the pipeline will automatically trigger all steps inside
- Consisitency -- Ensure that the exact same transformation logic is applied on both the training and test sets.
- Prevent data leakage -- In cross-validation, Pipeline ensures that the preprocessing logic is fitted only based on the training fold.

##### Method constraints

- Intermediate step -- All must be *transformers* that is -- they must have `fit()`and `transform()`
- The last step -- Can be any type -- Converter, classifier, regression , etc. If it’s a model, then the entire pipeline works like a model.

##### How Pipeline works

When calling `fit()`-- 

1. Call `fit()`for the first step, then `transform()`the data.
2. Pass the converted data to the second step.
3. Repeat this process until the last step.
4. When call `transform()`or `predict()`-- The data goes through `transform()`for each step in turn, but no longer fits, this ensures that the test data is processed using parameters learned by the training set, such as median or mean.

And if U don’t want to name the transformers, you can use `make_pipeline()`function instead, it takes transformers as positional arguments and creates a `Pipeline`using the names of the transformer’s classes, in lowercase and without underscores.

```python
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler

num_pipeline = make_pipeline(SimpleImputer(strategy="median"), StandardScaler())
```

Instead of manually writing a tuple list, `make_pipeline`handles naming automatically -- 

Naming Conflict Handling -- if put in two converter of the same kind -- will automatically append numeric indexes as `foo-1`and `foo-2`. And when call `Pipeline’s fit()`, opens a chain reaction -- 

1. Intermediate step -- calls `fit_transform()`sequentially for all transformer except the last step.
2. Data pass -- the output of each step serves as an input parameter for the next step.
3. Final step -- when the last estimator is reached, the pipeline only calls the `fit()`method on it.

##### The changeable identity of the pipeline

A powerful feature of Pipeline is that it *inherits* all the methods of the last step estimator -- 

- Scenario A -- The last step is the Transformer fore, if the last step ia s a `StandardScaler()`, then pipeline is just a converter in itself
  - It has a `transform()`method
  - Calling `pipeline.transform(X)`applies all transformation to the data in order.
- Scenario B -- The last step is the Predictor -- If the last is a classification or regression model, then the Pipeline becomes a predictor.
  - Has a `predictor()`method
  - Calling `pipeline.predict(X)`-- it preprocesses the adata through al the previous steps and then gives the processed data to the model to generate predictions.

| **Types of last steps**               | **Pipeline exposure method**              | **Typical uses:**                              |
| ------------------------------------- | ----------------------------------------- | ---------------------------------------------- |
| **Transformer** fore `StandardSclaer` | `fit()`, `transform()`, `fit_transform()` | Pure feature engineering/pretreatment pipeline |
| **Predictor** ( RF, SVM)              | `fit()`, `predict()`, `score()`           | A complete "end-to-end" model pipeline         |

Then call the pipeline’s `fit_transform()`method -- first

```python
from sklearn import set_config
set_config(display='diagram')
num_pipeline
```

Then call the pipeline’s `fit_transform()`method and look at the output’s first two rows -- like:

```python
housing_num_prepared = num_pipeline.fit_transform(housing_num)
housing_num_prepared[:2].round(2)
```

As can see earlier, if want to recover a nice DataFrame, you can use the pipeline’s `get_feature_names_out()`method -- just like:

```python
df_housing_num_prepared = pd.DataFrame(
    housing_num_prepared, columns=num_pipeline.get_feature_names_out(),
    index=housing_num.index)

num_pipeline.steps
```

And, Pipeline is designed to be flexible, supporting *indexing and slicing* like Python lists, as well as providing multiple ways to access internal steps -- with `ColumnTransformer`-- can consolidate multiple pipelines for different column into one *all-in-one* preprocessing engine.

1. Access the internal components of the pipeline -- U can explore the internal of a pipeline like an array or dictionary -- Fore, index vs slicing -- 
   - `pipeline[1]`-- Returns the 2nd estimator in the pipeline
   - `pipeline[:-1]`
2. Property Access - 
   - `steps`prop -- Returns a list *containing tuples*
   - `name_steps`-- this is a `dict`that maps step names to estimator objects.

##### Use `ColumnTransformer`to create *all-in-one converter*

In real projects, numerical and categorcal columns often require different processing logic `ColumnTransformer`allow us to stitch this logic together. The code is like: 

```python
from sklearn.compose import ColumnTransformer

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

First we import the `ColumnTransformer`class, then we define the list of numerical and categorial column names and constructs a simple pipepine for categorial attributes. Lastly, construct a `ColumnTransformer`. It constructor requires a list of triples -- each containing a name, a transoformer, and a list of names of columns that the transformer should be applied to.

##### Construction rules for triplets

For `ColumnTransformer`, receives a list of 3-tuples, each containing the following -- 

- `Name`-- must be unique and must not contain a `__`
- `Transformer`-- Can be a simple transformer or a complete `pipeline`
- Target columns -- which should be transformer work on. can use column name lists, integer indexes, and even boolean masks.

### Micmiking a long-running query

To help demonstrate how this all works, let’s start by adapating our dbs model’s `Get()`method so that it mimics a long-running query. Specially, update our SQL query to return a `pg_sleep(8)`value, which will make PostgreSQL sleep for 8 seconds before returning its result.

```go
func (m MovieModel) Get(id int64) (*Movie, error) {
    if id < 1 {
        return nil, ErrRecordNotFound
    }
    query := `
    	SELECT pg_sleep(8), id, created_at, title, year, runtime, genres, version
    	FROM movies
    	WHERE id = $1
    `
    var movie Movie
    
    err := m.DB.QueryRow(uery, id).Scan(
        &[]byte{},
        &movie.ID, 
        &movie.CreatedAt,
        &movie.Title,
        &movie.Year,
        &movie.Runtime,
        pq.Array(&movie.Genres),
        &movie.Version,
    )
    
    if err != nil {
        switch {
        case errors.Is(err, sql.ErrNoRows):
        	return nil, ErrRecordNotFound
        default:
            return nil, err
        }
    }
    return &movie, nil
}
```

```sh
 curl -w '\nTime: %{time_total}s \n' localhost:4000/v1/movies/1
```

#### Adding a query timeout

Now that we’ve got some code that mimics a long-running query, let’s enforce a timeout so that the SQL query is automatically canceled if it doesn’t complete within 3 seconds.

To do this we need to -- 

1. Use the `context.WithTimeout()`function to create a `context.Context`instance with a 3s timeout deadline.
2. Execute the SQL query using the `QueryRowContext()`method, passing the `context.Context`instance with 3-second timeout deadline.

```go
func (m MovieModel) Get(id int64) (*Movie, error) {
    if id<1 {
        return nil, ErrRecordNotFound
    }
    query := `SELECT pq_sleep(8), id, created_at, title, year, runtime, genres, version
    	FROM movie
   	`
    var movie Movie
    ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
    defer cancel()
    
    err := m.DB.QueryRowContext(ctx, query, id).Scan(...)
    if err != nil {
        switch {
        case errors.Is(err, sql.ErrNoRows):
            return nil, ErrRecordNotFound
        default:
            return nil, err
        }
    }
    return &movie, nil
}
```

