# Pre-Model and Data Preprocessing

The reality is that a data scientist spends about 80% of their time cleaning and preparing data. Noted -- *Garbage in, Garbage out* -- isn’t just a catchy prase -- 

1. Handling Missing data -- Real-world datasets are rarely complete, you generally have 3 choices when dealing with NaN values -- 
   - Elimination -- deleting for missing values
   - Imputation -- filling the gaps
   - Advanced Impuluation -- Using algs to predict what the missing value should be based on other features.

#### Common data issues

Some of the most common instances of data quality issues in ML model development include the following -- 

- Missing data -- incomplete dataset are common in real-world scenairos.
- *outliers* -- can distort statistical analysies and lead to misleading results. Techniques such as Z-score analysis or using scalars such as RobustScalar() can help migrate their impact.
- Categorical variables -- Many ML algs require numerical input -- thus, categorical variables need to be transormed into a suitable foramt. Using `OneHotEncoder`and `LabelEncoder()`
- Feature scaling -- Features with different scales can netatively affect model convergence and performance, especially for algorithm that rely on distance metrics. Fore, `KNN`, `StandardScalar()`and normalization -- fore `MinMaxScalar()`are common tech used to scale features appropriately.
- Data Leakage -- This occurs when info from *outside* the training dataset is used to create the model. Leading to overly optimistic perforance metrics.

#### Cleaning and preparing data -- 

This text highlights that Scikit-learn offers powerful data preprocesing tools that are essential for building robust, high -performance maching Learning models.

- `Pipeline()`-- Concatenates preprocessing steps with model training, streamling the process and ensuring data transformations for both training and test sets.
- `ColumnTransformer()`-- Capable of handling mixed-type datasets -- applying different preprocessing strategies to different columns.
- `sklearn.feature_selection`-- Utilize techniques like `SelectFromModel`and `RFE`to preserve the most relevant featurs, reducing model complexity and improving interpretability.

#### Handling missing data -- 

- Deletion method -- if the dataset is large enough, records containing missing values can be deleted directly, but this is not always a feasible scenario
- Imputation - This is more commonly used strategy.

This recipe intoduces 3 of the most commonly used methods for imputing missing values in a dataset with scikit-learn.

##### Getting ready -- 

```python
np.random.seed(2024) # for reproducibility
n_samples = 20
n_features = 10

data = {
    f"Feature{i+1}": np.random.uniform(0, 100, n_samples) for i in range(n_features)
}

df = pd.DataFrame(data)
for column in df.columns:
    mask = np.random.random(n_samples) < 0.2
    df.loc[mask, column] = pd.NA
```

There are a variety of methods for dealing with missing data -- scikit-learn contains 3 approaches -- `SimpleImputer()`, `KNNImputer()`and `InteractiveImputer()`-- they are outlined next -- 

Using the `SimpleImputer()`class -- the `SimpleImputer`is one of the most straightforwad methods for handling missing values. It allows users to replace missing entries with a specified statsitc such as the mean, median, or most frequent value. 

```python
from sklearn.impute import SimpleImputer
imputer = SimpleImputer(strategy='mean')
imputed_data = imputer.fit_transform(df)
imputed_df = pd.DataFrame(imputed_data, columns=df.columns)
```

The first six rows of imputed dbs can be seen in the following figure, you will notice that the missing data `NaN`from the original dataset has been replaced.

##### Using the `KNNImputer()`class -- 

For more complex dataset, `KNNImputer()`can be employed -- this method ues the KNN algorithm to impute missing values based on the values of neighboring samples -- Simpy put, `KNNImputer()`takes each missing value and identifies the nearest labled values in the dataset’s feature space -- then based on the majority label appearing among those values, the missing value is assigned the same.

`KNNImputer()`identifies the closest labled value in the feature space of the dataset for each missing value -- the value is then given to the missing position based on the most frequently occuring lable of these values.

```python
from sklearn.impute import KNNImputer

knn_imputer = KNNImputer(n_neighbors=2) # initialize
# Fit and transform data using the previously defined imputer
knn_imputed_data = knn_imputer.fit_transform(df)
pd.DataFrame(knn_imputed_data, columns=df.columns)
```

For the `n_neighbors=2`, Locate the nearest one -- find the 2 complete samples closest. Calculate the fill value -- If it is a numeric feature, takes the *average* of the corresponding values of two neighborbors. If it’s a categorical/discrete feature, infers based on the neighbor’s perfromance -- 

| **n_neighbors **              | **Effect**                                                   | **Risk**                                                     |
| ----------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| **Smaller values (e.g. 2)**   | The fill value is very influenced by the "neighbor" and captures local subtle features. | Susceptible to **noise or outliers**. If the two most recent points are exactly outliers, the fill result will be distorted. |
| **Larger values (e.g., 10+)** | The padding values are smoother and represent the local overall trend of the dataset. | It can smooth out subtle differences in the data, resulting in populated results that are too "mediocre". |

For this `KNNImputer(n_neighbors=2)`-- means that if the `age`item is missing from Sample A, the model will find the two closest sample B and C to *other characteristics of sample A* -- (20+30)/2 = 25

- scikit-learn’s default is 5 -- this is usually a relatively stable compromise
- Best practice -- Unless your dataset is very small, `n_neighbors=2`may be slightly too small and can easily cause the model to overfit to noise.

##### Using the `IterativeImputer()`class

`IterativeImputer()`offers an advanced approach by modeling each feature with missing values as a function of other features in a round-robin fashion.

1) working principle -- Using Round-robin way -- 
   - The features within the missing values are taken as the target variable (`y`) and rest of the features are used as input variable x.
   - Construct a regression model to predict and fill in the missing values of the feature, repeating the process for each missing feautre.
2) Core benefits -- It takes full advantage of the multiariate relationships between features in the dataset, so it often provides more accurate imputation results than simple methods.

```python
from sklearn.experimental import enable_iterative_imputer
from sklearn.impute import IterativeImputer
iterative_imputer = IterativeImputer()
iteraive_imputed_data = iterative_imputer.fit_transform(df)
pd.DataFrame(iteraive_imputed_data, columns=df.columns)
```

`IteraveImputer`logic is more advanced than simple mean impuding or distance-based KNN putting -- it essentially solves every feature with a missing value as an regression problem.

Provides guidance for selecting missing value imputation strategies, emphasizing that specific methods should be determined based on data characteristics and the degree of missing -- 

1. Decision factors -- 
   - Data type -- Numerical features can be used as mean or median, and categorical features are Usually mode
   - Data Distribution -- The distribution determines whether to use a simple method or a complex method
   - Analyze whether the data is complete random or regularly missing.
2. Summary recommendation based on missing proportions -- 

| **Missing Data Ratio** | **Recommended Method**                 | **Reason / Best Practice**                                   |
| ---------------------- | -------------------------------------- | ------------------------------------------------------------ |
| **Low (< 5%)**         | `SimpleImputer()`                      | Low computational cost and minimal bias introduced at this scale. |
| **Moderate (5–10%)**   | `KNNImputer()` or `IterativeImputer()` | Use **KNN** for purely numerical data; use **Iterative** for mixed data types to capture complex correlations. |
| **High (> 10%)**       | **Feature Removal**                    | If the loss is concentrated in one column, dropping it is often safer. Only impute if the feature is mission-critical. |

Exceptions that do not require imputationo -- Not all datasets need to be imputed, Algorithms such as Decision Trees and Random Forests can automatically handle features that contain missing values.

## Creating a new Movie

Begin with the `Insert()`method of our database model and update this to create a new record in our `movies`table. Speically, want to execute the following SQL query.

```sql
INSERT INTO movies (title, year, runtime, genres)
VALUES ($1, $2, $3, $4)
RETURNING id, created_at, version
```

- Uses the `$N`notation to represent *palceholder* parameters for the data what U want to insert the movies table. We explained -- every time pass untrusted input data from a client to a SQL dbs, it’s important to use placeholder parameters to help prevent SQL attacks, unless have a very specific reason for not using them.
- Only inserting values for `title, year, runtime`and `genres`. The remaining columns in the `movies`table will be filled with system-generated values at the moment of insertion -- the `id`will be an auto-increment integer, and the `created_at`and `version`values will default to current time and 1 respectively.
- And the end of the query have a `RETURNING`clause, this is a PostgreSQL-specific clause that U can use to return values from any record that is being manipulated by an `INSERT, UPDATE`or `DELETE`statement. In this query we are using it to return the system-generated `id, created_at`and `version`values.

Normally, would use Go’s `Exec()`method to execute an INSERT statement against a dbs table. But cuz our SQL query is returning a single row of data -- need to the `QueryRow()`method here instead.

```go
func (m MovieModel) Insert(movie *Movie) error {
	query := `
		INSERT INTO movies (title, year, runtime, genres)
		VALUES ($1, $2, $3, $4)
		RETURNING id, created_at, version`

    // Create an args slice containing the values for the placeholder parameter from 
    // the movie struct, declaring this slice immediately next to our SQL query helps to 
    // make it nice and clear *what valus are being used where* in the query.
	args := []any{movie.Title, movie.Year, movie.Runtime, pq.Array(movie.Genres)}

	// Create a context with 3s timeout.
	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()
	return m.DB.QueryRowContext(ctx, query, args...).Scan(&movie.ID, &movie.CreatedAt, &movie.Version)
}
```

##### Hooking it up to our API handler -- 

Now for the exciting part, hook up `Insert()`method to our `createMovieHandler`so that our `POST /v1/movies`endpoint works in full. Fore:

```go
func (app *application) createMovieHandler(w http.ResponseWriter, r *http.Request) {
    var input struct {
        Title string 		`json:"string"`
        Year int32 			`json:"year"`
        Runtime data.Runtime `json:"rutnime"`
        Games []string 		`json:"genres"`
    }
    err := app.readJSON(w, r, &input)
    if err != nil {
        app.badRequestResponse(w, r, err)
        return
    }
    
    movie := &data.Movie {
        Title: input.Title,
        Year: input.Year,
        Runtime: input.Runtime,
        Genres: input.Genres,
    }
    
    v := valiator.New()
    if data.ValidateMovie(v, movie); !v.Valid() {
        app.failedValidationResponse(w, r, v.Errors)
        return
    }
    
    // then call the `Insert()` method on our movies model, passing in a pointer to the
    // validated movie struct.
    err = app.models.Movies.Insert(movie)
    if err != nil {
        app.serveErrorResponse(w, r, err)
        return
    }
    
    // When sending a HTTP Response, want to include a location header to let the 
    // client know which URL they can find the newly-created resource at. We make an
    // empty http.Header map then use the `Set()` method to add a new location header.
    headers := make(http.Header)
    headers.Set("Location", fmt.Sprintf("/v1/movies/%id", movie.Id=D))
    
    err = app.writeJSON(w, http.StatusCreated, envelope["movie", movie], headers)
    if err != nil {
        app.serverErrorResponse(w, r, err)
    }
}
```

Can see that the JSON response contains all the info for the new movie.