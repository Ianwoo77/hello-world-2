# Feature engineering -- 2

Two main activities -- feature extraction and feature selection. Efective feature engineering can significantly enhance model performance by providing algorithms with more infomrative inputs and reducing or removing *noisy* and/or uninformative ones.

1. Creating new features -- this involves tansforming existing data into new variables that may capture important patterns or relationships -- might dervie a total spending feature by combining *price* and *quantity features.*
2. Selecting relevant features -- this process identifies and retains the most informative features while discarding those that do not contribute meaningful to the model’s predictive power.

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

#### Common matematical transformations -- 

Can create new features by applying mathematical transformations to existing ones. Fore -- 

- `PolynomialFeatures()`-- generate polynomial and interaction features from existing numerical featurs.

```python
from sklearn.preprocessing import PolynomialFeatures

# initialize the PolynomialFeatures
poly = PolynomialFeatures(degree=2)

# Fit and transform the X_train_transformed data
# output shows a subset of the final results
poly_features = poly.fit_transform(X_train_transformed)
poly_features_df = pd.DataFrame(poly_features, 
                                columns=poly.get_feature_names_out())

poly_features_df.head()
```

`poly.fit_transform(X_train_transformed)`-- 

- `Fit`-- learn the feaure dimensions and names of the raw data.
- `Transform`-- performs mathematcial calculations to generate a new matrix with square and intesecting terms.
- `poly.get_feature_names_out()`-- this is a very critical step -- This func automatically generates the name of the new feature making it easy for us to track the meaning of each number.

##### `KBinsDiscretizer()`

This alg works by converting continuous variables into categorical ones by binning them into discrete intervals -- Think of it like creating buckets. Transforms continuous numerical features into discrete bins. Think of it as turning a smooth curve into labeled chunks. Fore:

- Works better with categorical inputs
- Want to reduce noise
- Want to capture non-linear relationships
- Want to simplify a feature into interpretable groups

```python
from sklearn.preprocessing import KBinsDiscretizer

# split each continus feature into 3 equal-width bins, represents each bin oridinal number
# and use uniform each bin as number (0, 1, or 2)
kbins_discretizer = KBinsDiscretizer(n_bins=3, encode='ordinal', strategy='uniform')

binned_data = kbins_discretizer.fit_transform(X_train_transformed)
binned_data_df = pd.DataFrame(binned_data, columns=X_train_transformed.columns)
binned_data_df.head()
```

For every value in every column, assigns it to a bin -- 

- Values in the first interval -> 0
- Values in the second interval -> 1...

### Classification

Ch2 explored a regression task, predicting housing values, using various alg such as linear regression, decision trees, and random forests -- now we will turn our attention to classification systems.

##### MINIST - 

In this chapter will be using the MNIST dataset, which is a set of 70,000 small images of digts handwritten by high school students and employees of the US . For Scikit-learn provides many helper functions to download popular datasets. MNIST is one of them - the following code fetches the MNIST dataset from like:

```python
from sklearn.datasets import fetch_openml

mnist = fetch_openml('mnist_784', as_frame=False)
```

For this, the sklearn.datasets package contains mostly 3 types of functions -- `fetch_*`functions such as `fetch_openml()`to download real-life datasets, `load_*`functions to load small toy datasets bundled with Scikit-learn, and make_* function to generate fake datasets.

1. sklearn’s 3 types of datasets in sklearn to get functions -- In the `sklearn.datasets`module, the functions that fetch the dataset are dividied into 3 main prefix -- 

   - `fetch_*`-- Used to downlaod real, large datasets from the internet
   - `load_*`-- used to load a small *toy* data set built into sklearn
   - `make_*`-- Used to randomly generate virtual (fake) datasets, often used to test algorithm models.

2. The return format of the dataset -- The data returned by different functions differs in the format -- 

   - `make_*`-- returns a `(X,y)`tuple directly, where `X`is the input and `y`is the target label, both are NumPy arrays
   - Other functions -- typically returns a *bunch* object. Can think of as it as an enhanced version of the Py dictionary, not only for extracting data with k-v pairs, but also directly with dots `.`-- as a property call, it typically contains the following 3 core conents -- 
     - `DESCR`, `data`-- input data/features, `target`-- The true label/classification results of the data.

3. Special `fetch_openml()`vs. MINIST datasets -- `fetch_openml()`-- it defaults to returning data in Pandas DF and Series format. However, the MNIST dataset is made up of image -- Pandas tables are not suitable for working with image pixel data, NumPy matrices are more suitable.

4. How to restore data to a picture -- 

   ```python
   mnist.keys()  # extra code – we only use data and target in this notebook
   X, y = mnist.data, mnist.target
   X, y
   
   import matplotlib.pyplot as plt
   
   def plot_digit(image_data):
       image = image_data.reshape(28, 28)
       plt.imshow(image, cmap="binary")
       plt.axis("off")
   
   some_digit = X[0]
   plot_digit(some_digit)
   save_fig("some_digit_plot")  # extra code
   plt.show()
   ```

Summary - The purpose of this passage is to teach U how to import data with sklearn, understand the underlying structure of image data, and use matplotlib to re-visualize boring number matrices into intutive images.

To give U a feel for the complexity of the classification task -- shows a few more images from the MNIST dataset -- should always create a test set and set it aside before inspecting the data closely -- the MNIST dataset returned by `fetch_openml()`is actually already split into a training set and a test set.

```python
X_train, X_test, y_train, y_test = X[:60000], X[60000:], y[:60000], y[60000:]
```

And, the training set is already shuffled for us -- which is good cuz this gurantees that all cross-validation folds will be similar.

#### Training a Binary Classifier

FORE, the number 5 -- the *5-detector* -- will be an example of *binary classifier*, capable of distinguishing between just two classes, 5 and non-5. First we will create the target vectors for this classification task. Just like:

```python
y_train_5 = (y_train == '5')  # True for all 5s, False for all other digits
y_test_5 = (y_test == '5')
```

Now let’s pick classifier and train it -- A good place to start is with a *stochastic gradient descent* -- `SGD`-- classifier, using Scikit-learn’s `SGDClassifier`class -- this classifer is capable of handling very large datasets efficiently. This is in part cuz SGD deals with training instances independently, one at a time.

- `SGDClassifier`-- uses stochastic gradient descent -- 
- It updates the model one training example at a time

```python
from sklearn.linear_model import SGDClassifier

sgd_clf = SGDClassifier(random_state=42)
sgd_clf.fit(X_train, y_train_5)
sgd_clf.predict([some_digit])
```

This classifier guesses that this image represens 5 `True`-- Looks like it guessed right in this particular case.

#### Performance Measures

Evaluating a classifier is often significantly tricker than evaluating a regressor, will spend a large part of this chapter on this topic. There are many performance measure available, so grab another coffee and get ready to learn a bunch of new concepts and acronyms.

##### Measuring Accuracy Using Cross-Validation

A good way to evaluate a model is to use corss-validtion, just as U did in -- Use the `cross_val_score`function to evaluate our `SGDClassifier`model, using `k-fold`cross-validation with 3 folds.

```python
from sklearn.model_selection import cross_val_score
cross_val_score(sgd_clf, X_train, y_train_5, cv=3, scoring="accuracy")
```

Here is the clearest explanation of what `cross_val_score`is and what your specific line of code does -- is a Scikit-learn function that performs `cross-valiation`automatically.

```python
from sklearn.dummy import DummyClassifier

dummy_clf = DummyClassifier()
dummy_clf.fit(X_train, y_train_5)
print(any(dummy_clf.predict(X_train)))
```

For this, classifier that always predicts not a 5 will be 90% accurate, cuz 90% of the images are not 5. But thi sis completely useless -- 

```python
cross_val_score(dummy_clf, X_train, y_train_5, cv=3, scoring="accuracy")
```

Also, has over 90% accuracy -- this is simply cuz only about 10% of the images are 5s -- so if always guess that an image is not 5, U will be right about 90% of the time.

##### Why choose SGD classifier 

Here chose a model called `SGDClassifier`as a starting point.

- Processing big data is very efficient -- can run fast with a dataset of tens of thousands of images like MNIST.
- Processing one sample at a time -- Unlike many algorithms that *have to eat all the data in one go*. SGD is one picture at a time, learn independently.
- Online learning -- Cuz it can process data one by one, if your system is already live and new data is constantly coming in, SGD can fine-tune itself in real time while receiving new data, without having to  retrain from scratch.

```python
# 1. 从 sklearn 的线性模型库中导入 SGDClassifier
from sklearn.linear_model import SGDClassifier

# 2. 创建一个模型实例（就像造了一个还没上学的机器人）
# random_state=42 是为了固定“随机种子”，确保你每次运行这段代码，机器人的初始状态都完全一样，方便复现结果。
sgd_clf = SGDClassifier(random_state=42)

# 3. 训练模型（关键步骤：让机器人上学）
# fit() 就是“拟合/训练”的意思。
sgd_clf.fit(X_train, y_train_5)
```

Just note that the gats used here are not regular `y_train`, but y_train_5 -- this means that the autor has simplified the binary classification here -- instead of asking the model to distinguish between 0 and 9 all numbers, he only asked the model to answer a question - is the graph *5*.

##### Testing the model

- `predict()`-- is a function is used to make predictions -- note that `some_digit`has a `[]`outside cuz the model requires that the input must be in the format of a batch of data, even if there is only one graph, to be included in a list.
- `array([True])`-- The answer given by the model is `True`.

In Scikit-Learn, we typically only need one line of the code to cross-valiation, but here the author teaches *how to code and implement this process from start to finish*.

1. For more control -- sometimes ready-made functions don’t meet complex needs, so u need to write your own loops
2. Core concept -- what is *Stratified Sampling* -- Used `StratifiedKFold`is used in this code, which is the key to understanding this code.

## Fitering, sorting, and Pagination

In this sectin of the book we are going to force on building up the functionality for a new `GET /v1/movies`endpoints. We will develop the functionality for this endpoint incremently.

Will develop the functionality - 

- Return the details of multiple resources in a single JSON response.
- Accept and apply optional filter parameters to narrow down the returned data set.
- Implement full-text search on your databse fields using PSQL’s inbuilt functionality.
- Accept and safely apply sort parameters to change the order of results in the data set.
- Develop a pragmatic, reusable, pattern to support pagination on large data sets, and return pagination medadata in your JSON responses.

### Parsing Query string Parameters

Fore /v1/movies?title=godfather&genres=crime,drama&page=1&page_size=5&sort=-year -- if a client sends a query string like this -- it is essentially saying to our API -- Please return the first 5 records where the movie name includes on the genres include `crime`and `drama`-- sorted by descending release year.

As can hopefully remember from -- can retreive query string data from a request calling the `r.URL.Query()`, this returns a `url.Values`type, which is basically a map holding the query string data. Can then extract values from this map using the `Get()`method, which will return the value for a specific key as a `string`type.

Ned to carry out extra post-processing on some of these query string values -- 

- The `genres`parameter will potentially contain multiple comma-separated values -- like `genres=crime,drama`. We will want to split these values apart and store them in a `[]string`slice.
- The `page`and `page_size`parameter will contain numbers, and will want to convert these query string values into Go `int`types -- 

In addition to that -- 

- There are some validation checks that we will want to apply to the query string values, like making sure the `page`and `page_size`are not negative numbers.
- Want our app to set some sensible *default* values in case parameters like `page`, `page_size`and `sort`aren’t provided by the client.

##### Creating helper functions

To assist with this, we are going to create three new helper functions -- `readString()`, `readInt`and `readCSV()`-- use these helpers to extract and parse values from the query string, or return a default fallback value if necessary.

```go
func (app *application) readString(qs url.Values, key string, defaultValue string) string {
	s := qs.Get(key)
	if s == "" {
		return defaultValue
	}
	return s
}

func (app *application) readCSV(qs url.Values, key string, defaultValue []string) []string {
	csv := qs.Get(key)
	if csv == "" {
		return defaultValue
	}
	return strings.Split(csv, ",")
}

// readInt helper reads a string value from the query string and converts it to an int
// before returning.
func (app *application) readInt(qs url.Values, key string, defaultValue int, v *validator.Validator) 
		int 
{
	s := qs.Get(key)
	if s == "" {
		return defaultValue
	}
	value, err := strconv.Atoi(s)
	if err != nil {
		v.AddError(key, "must be an integer value")
		return defaultValue
	}
	return value
}
```

Adding the API handler and route -- Create a new `listMovieHandler`for our `GET /v1/movies`endpoint. For now, this handler will simply parse the request query string using the helpers we just made, and the dump the contents out in an HTTP response.