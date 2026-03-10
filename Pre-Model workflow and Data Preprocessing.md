# Pre-Model workflow and Data Preprocessing

- The impact of raw data on model performance
- Handling missing data
- Scaling techniques
- Encoding categorcial variables
- Introuction to pipeline in scikit-learn
- Feature engineering

Common data issues -- Some of the most instances of data quality issues in ML model development include the following -- 

- Missing data -- Incomplete datasets are common, Can use `SimpleImputer`or `KNNImputer()`.
- Outliers -- Can distort statistical analyses and lead to misleading results. Identifying and treating outliers is vital for maintaining the integrity of your model. Z-score analysis or using scalers such as `RobustScaler()`can help mitgrate their impact.
- Categorical variables -- Many ML algorithms require numerical input -- categorical variables need to be transformed into a suitable format. Using such as `OneHotEncoder`and `LabelEncoder()`to facilitate the transformation.
- Feature scaling -- Features with different scales can negatively affect model convergence and performance, especially for algorithms that rely on distance metrics -- KNN, `StandardScaler`and normalization. Fore.
- Data leakage -- Occurs when info from *outside* the training dataset is used to create the model, leading to *overly optimistic performance metrics*.

#### Cleaning and preparing data

- `Pipeline()`-- Allows users to streamline their preprocesing steps alongside model training, ensuring that all transformation are applied consistently acorss training and testing datasets.
- `ColumnTransformer()`-- Datasets with mixed types of features.
- `sklearn.feature_selection`-- Such as `SelectFromModel()`and Recursive Feature Elimination help identify and retain only the most relevant features for model training, reducing complexity and improving interoperability.

##### Handling missing data -- 

Missing data can arise from various sources, So is important to address missing valus before training ML models, as most algorithms cannot handle them directly, and most scikit-learn methods wo’t even execute when are detected in your training data. Sometimes, with *large enough* datasets, can *simply* drop the records contain missing values with little impact on the resulting model -- but this isn’t always viable.

```python
data = {
    f"Feature{i+1}": np.random.uniform(0, 100, n_samples) for i in range(n_features)
}
```

In the context of Py and NumPy, The main difference between them and `uniform()`is the *flexibility of scope* and *the setting of parameters*.

| ** Characteristics**  | **np.random.rand()**                                | **np.random.uniform(low, high, size)**                       |
| --------------------- | --------------------------------------------------- | ------------------------------------------------------------ |
| **Scope Limits**      | **Fixed** $[0, 1)$ between .                        | **Customize** the scope (such as $[0, 100)$ ).               |
| **Parameter passing** | Enter dimensions directly (such as `rand(3, 2)).`   | `uniform(0, 5, size=(3, 2))`）。 Enter boundary values and shapes (e.g. `uniform(0, 5, size=(3, 2))).` |
| **Flexibility**       | lower, only for standard normalized random numbers. | **high**, which can simulate uniform data for any interval.  |

Mathematical Relationships -- `np.random.uniform(0, 100, size)`effectively equivalent to `np.random.rand(size)*100`

In real-world machine learning tasks, most matrual phenomena -- follow normal distribution -- also known as *Gaussian distribution*. Can use just the `np.random.normal()`to genreate this kind of data.

Generate normally distributed data - Unlike `uniform()`, `normal()`requires two core parameters to define the shape of the curve -- `loc`-- the center of the distribution, `scale`-- the degree of discretion of the data.                                

```python
import numpy as np
import matplotlib.pyplot as plt

n_samples = 1000

# 1. 均匀分布 (Uniform) - 每个数概率相等
uniform_data = np.random.uniform(0, 100, n_samples)

# 2. 正态分布 (Normal) - 均值为50，标准差为15
normal_data = np.random.normal(loc=50, scale=15, n_samples)

plt.figure(figsize=(10, 4))

plt.subplot(1, 2, 1)
plt.hist(uniform_data, bins=30, color='skyblue', edgecolor='black')
plt.title("Uniform Distribution (0-100)")

plt.subplot(1, 2, 2)
plt.hist(normal_data, bins=30, color='salmon', edgecolor='black')
plt.title("Normal Distribution ($\mu=50, \sigma=15$)")

plt.show()
```

Then just generate some data including `NaNs`. Fore:

```python
df = pd.DataFrame(data)
for column in df.columns:
    mask = np.random.random(n_samples) < 0.2
    df.loc[mask, column] = pd.NA
```

And, there are variety of methods for dealing with missing data. scikit-learn contains 3 approaches -- `SimpleImputer()`, `KNNImputer()`and `InterativeImputer()`-- there are outlined next.

##### Using the `SimpleImputer()`class -- 

The `SimpleImputer()`class in scikit-learn is one of the most straightforward methods for handling missing values.

```python
from sklearn.impute import SimpleImputer
imputer = SimpleImputer(strategy='mean')
imputed_data = imputer.fit_transform(df)
imputed_df = pd.DataFrame(imputed_data, columns=df.columns)
imputed_df
```

After app, can see that the result of `SimpleImputer()`.

##### Using the `KNNImputer()`class

For more complex datasets, `KNNImputer()`can be employed. This method uses the KNN algorithm to impute missing values based on the values of neighboring samples. For the `KNNImputer`-- it does not look at the average of *this column* -- but at other characteristics of *this row* -- to find the neighbor that is most similar to it, and then refer to the value of the neighbor in the missing column.

```python
from sklearn.impute import KNNImputer

knn_imputer = KNNImputer(n_neighbors=2) # initialize
# Fit and transform data using the previously defined imputer
knn_imputed_data = knn_imputer.fit_transform(df)
pd.DataFrame(knn_imputed_data, columns=df.columns)
```

##### Using the `IterativeImputer()`class -- 

Offers an advanced approach by modeling each feature with missing values as function of other features in a round-robin fashion. The method models eash feature with a missing value as a *regression function*. Subsequently, the regression model is used to predict the missing value of the feature. This process is repeated for each feature that contains the missing value. Fore, `SimpleImputer`is simple statistics and `KNNImputer`is looking for neighbors, then `IterativeImputer`is *experimenting*. Fore: A and B both have missing values

1. Temporarily fill in missing B with simple value first
2. With A as the target variable `y`and B and C as independent variables X, train a regression model to predict the missing value of A.
3. A filled, in turn, B is used as the target variable `y`and B is predicted with A and C.
4. Cyclic iteration -- Repeat this process until the filled value stabilizes.
5. Accuracy is usually highest with global correlation -- Large calcuation overhead.

```python
# epperimental feature requires loading
from sklearn.experimental import enable_iterative_imputer
from sklearn.impute import IterativeImputer
iterative_imputer = IterativeImputer()
iteraive_imputed_data = iterative_imputer.fit_transform(df)
iterative_imputed_df = pd.DataFrame(iteraive_imputed_data, columns=df.columns)
iterative_imputed_df
```

### Handling Text and Categorical Attributes

So far, have only dealt with numerical attributes, but your data may also contain text attributes, in the dataset, there is just one - the `ocean_proximity`attribute -- 

```python
housing = strat_train_set.copy()
housing_cat = housing[["ocean_proximity"]]
housing_cat.head(8)
```

Note that it’s not arbitrary text, there are a limited number of possible values, each of which represents a category. So this attribute is a categoical attribute. Most ML algs prefer to work with numbers, so need to conver these categories from text to numbers -- fore `OridnalEncoder`class - like:

```python
from sklearn.preprocessing import OrdinalEncoder
ordinal_encoder = OrdinalEncoder()
housing_cat_encoded = ordinal_encoder.fit_transform(housing_cat)
```

One issue with this representation is that ML algs will assume that two nearby values are more similar than two distant values. When dealing with text categories, a common mistake beginners make is to simply number them in order, such as `apple=0, banana=1, cherry=2`-- This is called label encoding. However, most machine learning algorithms learn by calculating the distance between numerical values.

When can Just use a number number -- And if the category itself has a high and low, size, and strength, it is reasonable to directly convert to 0, 1, 2, 3 -- 

##### Take the California Home price Data Set as an Example

If they are represented by the numbers 0~4, the algorithm calculates the distance -- but in fact, 0 and 4 are both coastal characteristics, and the similarity between them should be extremly high, while is completely different from them. As a result, number encoding is grossly misleading aobut machine learning models.

- *One-hot* -- Like a circuit, only one wire in a group of wire is energized and the others are powered off.
- Dummy variable -- This is the name in statistics, in traditional statistical analyses -- categorical data are often represented by introducing dumb variables containing only 0 and 1.

```python
from sklearn.preprocessing import OneHotEncoder
import numpy as np

# 假设这是我们的原始数据（二维数组）
data = np.array([['<1H OCEAN'], ['INLAND'], ['NEAR OCEAN']])

# 初始化独热编码器
encoder = OneHotEncoder(sparse_output=False) # sparse_output=False 为了直观显示为普通数组

# 转换数据
one_hot_data = encoder.fit_transform(data)

print(one_hot_data)
# 输出:
# [[1. 0. 0.]  -> 代表 <1H OCEAN
#  [0. 1. 0.]  -> 代表 INLAND
#  [0. 0. 1.]] -> 代表 NEAR OCEAN
```

Alternatively, Can set `sparse=False`when creating the `OneHotEncoder`-- in which case the `transform()`will return a regular Numpy array directly.

```python
cat_encoder.categories_
```

For this, Pandas has a func called `get_dummies()`-- which also converts each categorical feature into a one-hot representation, with one binay feature per category.

```python
df_test = pd.DataFrame({"ocean_proximity": ["INLAND", "NEAR BAY"]})
pd.get_dummies(df_test)
```

And the advantage of `OneHotEncoder`is that it remembers which categories it was trained on. This is very important cuz once your model is in production, it should be fed exactly the same features as during training -- no more, no less. For this, if using -- 

```python
cat_encoder.transform(df_dest)
array([[0, 1, 0, 0, 0],
       [0, 0, 0, 1, 0]])
```

`get_dummies()`saw only two categories, so it outtout two columns, whereas `OneHotEncoder`output one column per learned category, in the just right order. And, if add an unknown cateogory fore `<2H OCEAN`it will happily generate a column for it like -- 

```python
df_test_unknown = pd.DataFrame({"ocean_proximity": ["<2H OCEAN", "ISLAND"]})
pd.get_dummies(df_test_unknown)
```

But the `OneHotEncoder`is smarter, will detect the unknown category and raise an exception.

```python
cat_encoder.handle_unknown = "ignore"
cat_encoder.transform(df_test_unknown).toarray()
```

And when fit any Scikit-learn estimator using DF, the estimator stores the column names in the `future_names_in`attribute. Scikit-learn then ensure that any DF fed to this estimator after that has the same column names.

```python
cat_encoder.feature_names_in_
cat_encoder.get_feature_names_out()
```

## Exeucting the SQL Query

Start in dbs model again, edit the `Update()`method to execute the SQL query -- Noticed that incrementing the `version`value as part of the query -- and then at the end we are using the `RETURNING`clause to return this new, incremented, `version`value -- 

```go
func (m MovieModel) Update(movie *Movie) error {
	query := `
		UPDATE movies
		SET title = $1, year = $2, runtime = $3, genres = $4, version = version + 1
		WHERE id = $5
		RETURNING version`

	args := []any{
		movie.Title,
		movie.Year,
		movie.Runtime,
		pq.Array(movie.Genres),
		movie.ID,
    }
    return m.DB.QueryRow(query, args...).Scan(&movie.Version)
}	
```

The `Update()`method just takes a pointer to a `movie`struct as the input parameter and mutates it in-place again. In the API just like -- 

```go
func (app *application) updateMovieHandler(w http.ResponseWriter, r *http.Request) {
	id, err := app.readIDParam(r)
	if err != nil {
		app.notFoundResponse(w, r)
		return
	}

	movie, err := app.models.Movies.Get(id)
	if err != nil {
		if errors.Is(err, data.ErrRecordNotFound) {
			app.notFoundResponse(w, r)
			return
		}
		app.serverErrorResponse(w, r, err)
		return
	}

	var input struct {
		Title   *string       `json:"title"`
		Year    *int32        `json:"year"`
		Runtime *data.Runtime `json:"runtime"`
		Genres  []string      `json:"genres"`
	}

	err = app.readJSON(w, r, &input)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}
    // Copy the values from the request body to the appropriate fields of the movie record
    movie.Title = input.Title
    //... Others fields
    
    // Validate the updated record, sending the client a 422 Unprocessable Entity
    v := validator.New()
    if data.ValidateMovie(v, movie) !v.Valid() {
        app.failedValidationResponse(w, r, v.Errors)
        return
    }
    
    // Pass the updated movie record t our new `Update()`
    err = app.models.Movies.Update(movie)
    if err != nil {
        app.serverErrorrResponse(w, r, err)
        return
    }
    
    // Write the updated in a JSON
    err = app.writeJSON(w, http.StatusOK, evelope["movie": movie], nil)
    //...
}
```

`router.HandlerFunc(http.MethodPut, "/v1/movies/:id", app.updateMovieHandler)`

##### Using the new endpoint

```sh
BODY='{"title":"Black Panther","year":2018,"runtime":"134 mins","genres":["sci-fi","action","adventure"]}'
curl -X PUT -d "$BODY" localhost:4000/v1/movies/2
```

#### Deleting a Movie

Add final CRUD so that a client can delete a specific movie from our system.
`DELETE /v1/movies/:id, deleteMovieHandler`-- Delete a specific movie.

Compared to the other endpoints, in our API, the behavior that we want to implement here is quite straightforward.

- If a movie with the `id`provided in the URL exists i the dbs, want to delete the corresponding record and return a success message to the client.
- If the movie `id`doesn’t exist, want to return a 404 Not Found response to the client.

In this case the SQL query returns no rows, so it’s appropraite for us to use Go’s `Exec()`method to execute it. One of the nice things about the `Exec()` is that it returns a `sql.Result`object, which contains information about the number of rows that the query affected -- in our scenario here, this is really useful info.

If the number of rows affected is 0 we know that no movie with that `id`existed at the point we tried to delete it.

#### Adding the new endpoint

Update the `Delete()`in the dbs model -- Essentially, want this to execute the SQL query above and return an `ErrRecordNotFound`error if the number of rows affected is 0.

```go
func (m MovieModel) Delete(id int64) error {
	if id == 0 {
		return ErrRecordNotFound
	}

	query := `
		DELETE FROM movies
		WHERE id = $1`

    // Execute the SQL query using the Exec() method, passing in the id variable as 
    // the value for the placeholder parameter.
	result, err := m.DB.ExecContext(ctx, query, id)
	if err != nil {
		return err
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return err
	}
    
    // If no rows were affected, we know that the movies didn't contain a record
    // with the provided ID at the moment we tried to delete it.
    if rowsAffected = 0 {
        return ErrRecordFound
    }
    return nil
}
```

Once done, add a new `deleteMovieHandler()`-- need to read the movie ID from the request URL, call the `Delete()`method that we just made.

```go
func (app *application) deleteMovieHandler(w http.ResponseWriter, r *http.Request) {
    // extract the movie ID from the URL
    id, err := app.readIDParam(r)
    if err != nil {
        app.notFoundResonse(w, r)
        return
    }
    
    // Delete the movie from the dbs, sending a 404 Not Found Response to the 
    // Client if there isn't matching record.
    err = app.models.Movies.Delete(id)
    if err != nil {
        switch {
        case errors.Is(err, data.ErrRecordNotFound):
            app.notFoundResponse(w, r)
        default:
            app.serverErrorResponse(w, r, err)
        }
        return
    }
    
    // Returns a 200 OK status code along with a success message
    err = app.writeJSON(w, http.StatusOK, envelope["message", "movie successfully deleted"], nil)
    if err != nil {
        app.serverErrorResponse(w, r, err)
    }
}
```

`router.HandlerFunc(http.MethodDelete, "v1/mvoies/:id", app.deleteMovieHandler)`

`-X`is shorter for `--request`-- which is used to specify the HTTP method used to communicate with the HTTP server. And `DELETE`requests are often destructive, Once successful, the piece of data on the server is usually removed or marked as deleted. Also note that in a std REST design, the same `DELETE`request is made multiple times and the result should be the same, although the server may return a 404 *Not Found* a second time.

### Advanced CRUD Operations

For this of the book going to look at a few more *advanced* patterns that U might want to use for the CRUD endpoints that your API provides -- 

- How to support *partial* updates to a resource 
- How to use *optimitic concurrency control* to avoid race conditions when two clients try to update the same resource at the same time.
- How to use *context timeouts* to terminate long-running dbs queries and prevent unnecessary resource use.

#### Handling Partial Updates

Going to change the behavior of the `updateMovieHandler`so that it supports *partial updates* of the movie records. Conceptually this is a little more complicated than making a complete replacement, which is why laid the groundwork whith that approach fit. Instead of all the movie data -- `{"year": 1985}`-- As mentioned eariler in the book, when decoding the request body any fields in our `input`struct which *don’t have a corresponding* JSON key/value pair will retain their *zero-value*.

In the context of partial update this causes a problem -- how do tell the difference between -- 

- A client providing a *key/value* pair which has a zero-value -- like `{"title": ""}`-- in which case want to return a validation error.
- A client not providing a *key/value* in their JSON at all.

| **Go Type Category**                                         | **Zero-Value**                                      |
| ------------------------------------------------------------ | --------------------------------------------------- |
| *pointer* for (`int`, `uint`, `float`, `complex`, `byte`, `rune`) | `0`                                                 |
| **String**                                                   | `""` (empty string)                                 |
| **Boolean**                                                  | `false`                                             |
| **Reference & Pointer Types** (`func`, `slice`, `map`, `chan`, `*type`) | `nil`                                               |
| **Arrays**                                                   | Elements initialized to their respective zero-value |

So, in theory, could change the fields in our `input`struct to be pointers. Then to see if a client has provided a particular k/v pair in the JSON - can simply check whether the corresponding field `input`struct equals `nil` or not.

#### Performing the partial update

Put this into practice, and edit our `updateMovieHandler`method so it supports partial updates as follows -- Just like 

```go
func (app *application) updateMovieHandler(w http.ResponseWriter, r *http.Request) {
    id, err := app.readIDParam(r)
    if err != nil {
        app.notFoundResponse(w, r)
        return
    }
    
    // Retreive the movie record as normal
    movie, err := app.models.Movies.get(id)
    if err != nil {
        switch{
        case errors.Is(err, data.ErrRecordNotFound):
            app.notFoundResponse(w, r)
        default:
            app.serverErrorResponse(w, r, err)
        }
        return
    }
    // use pointers for the `Title, Year, and Runtime fields`
    var input struct {
        Title *string `json:"title"`
        Year *int32 `json:"year"`
        Runtime *data.Runtime `json:"runtime"`
        Genres []string `json:"genres"`
    }
    
    // Decode the JSON as normal
    err = app.readJSON(w, r, &input)
    
    if input.Title != nil {
        movie.Title = *input.Title
    }
    // ... also do the same for the other fields in struct
    //...
    if input.Generes != nil {
        movie.Genres = input.Genres
    }
    
    v := validator.New()
    if data.ValidateMovie(v, movie); !v.Valid() {
        app.failedValidationResponse(w, r, v.Errors)
        return
    }
    
    err = app.models.Update(movie)
    if err != nil {
        app.serverErrorResponse(w, r, err)
        return
    }
    
    //.. write to JSON
}
```

For this, have changed our `input`struct so that all the fields now have the zero-value `nil`-- after parsing the JSON, then go through the `input`struct fields and only update the movie record if the new value is not `nil`. In addition to this, for API endpoints which perform *partial updates* on a resource, it’s appropriate to use the HTTP method `PATCH`rather than `PUT`. Just like:

`router.HandlerFunc(http.MethodPatch, “/v1/movies/:id”, app.updateMovieHandler)`

```sh
curl -X PATCH -d '{"year": 1985}' localhost:4000/v1/movies/4 # -d for *data*
```

Then can seee that the `year`value has been correctly updated, and the `version`number has been incremented.

##### `null`values in JSON -- 

If `curl -X patch -d {"title": null, "year": null} localhost:4000/v1/movies/4` this would result in *no changes* to the movie record -- but `version`number also be incremented.

