# Scikit-learn -- Clean the Data

Most machine learning algorighms cannot work with missing features, So, you will need to take care of these -- fore, U noticed earliear that the `total_badrooms`

```python
from sklearn.model_selection import train_test_split
train_set, test_set = train_test_split(housing, test_size=0.2, random_state=42)
```

Setting up a sandard hold-out validation for a housing dataset. This is just a crucial step in any machine learning pipeline to ensure your model doesn’t just memorize the data but actually learn to generalize to new, unseen houses.

##### Breakdown of the code -- 

- `housing`-- full dataset
- `test_size=0.2`-- allocating 20% of your data for testing and 80% for training. common split, though might go 90/10 if your data set is massive.
- `random_state=42`-- Seed for the random number genertor. Using a fixed number just ensures that every time you run this script - get the *exact same split*. This is vital for *reproducibility* -- If U didn’t set this, your test data would change every time you restarted your notebook.

### Scikit-learn Design

Scikit-learn’s API is remarkable well designed -- 

#### Consistency -- the 3 interfaces

Scikit-learn uses Duck typing, if an object walks like a duck and quacks like duck, it is treated as a duck -- this means that don’t always strictly need inheritance, U just need to implement the specific method, `fit, transform, predict`-- 

- Estimators (`fit`)
  - The concept -- this logic for *learning* -- 
  - Separation of concerns -- Scikit-learn strictly separate Hyperparameters -- how the model learns from parameters. *hyperparameters* are just passed to the class ctor -- fore, `KneibhborClssifier(n_neighbors=5)`
  - Parameters are learned when `fix(X,y)`is called.
  - Implication -- can instaniate a model configured without any data, in a cold state, until `fit`called.
- Transfomer (`transform`)-- These modify data to make it suitable for ML. the workflow is like:
  - `fit(train_data)`-- Learn the statistics
  - `transform(train_data)`-- apply the statistics to the training data
  - `transform(test_data)`-- apply the same statics leaned from training to the test data.
  - Optimization -- the `fit_transform()`method is often computationally more efficient than calling `fit()`then `transform()`.
- predictors - Applying the learned patterns to new data. 
  - `predit(X)`returns the class lable or regession values.
  - `predict_proba(X)`-- return the probability/confidence
  - `score(X,y)`-- A shortcut to evalute performance.

##### Transparency & Debugging

Scikit-learn models are transparent -- 

- Underscore Suffix convention -- Any attribute ending an *underscore* is a value calculated after the `fit()`method was run.
- Access Cuz there are std public attributes, can easily inspect them to understand the model logic. Fore, check `lin_reg.coef_`tells U exactly how much weight model assigned to a specific feature

##### Nonproliferation of Classes -- Interoperability

This is arguably the most important desgin for the Py ecosystem.

- No custom Data Wrapper -- Skilit-learn does not require U to convert data into a propritary obj, it just accetps -- Fore, Numpy Arrays, Scipy sparse Matrices (text processing generally), and DF.
- Standard types -- Inputs and outputs are simple Py strings...

##### Compostiong -- the pipeline -- 

Cuz every object shares the same interface, `fit/transform`, chain them together like LEGO blocks.

- The pipeline object -- can wrap a sequence of transformers and a finle Estimator into a single object
- Benefits -- 
  - Code Reduction -- call `fit`once on the pipeline, and automatically fits/transforms every step in sequence.
  - Safety -- prevents Data leakage.

##### Sensible Defaults -- 

Scikit-learn prioritize *convention over configuration* -- 

- User experience -- can initialize almost any model like `model=RandomForestClassifier()`without arg, and it will run -- 
- The defaults are chosen based on academic literature and best practices to provide a good enough baseline, this allows users to get a working prototype immediately and then tune hyperparameters later.

```python
from sklearn.impute import SimpleImputer
from sklearn.linear_model import LinearRegression
from sklearn.pipeline import Pipeline
import numpy as np

# 1. NONPROLIFERATION: Using standard NumPy arrays
X_train = np.array([[10, 2], [5, np.nan], [12, 5]]) # Missing data in 2nd row
y_train = np.array([20, 10, 24])

# 2. COMPOSITION: Chaining a Transformer and a Predictor
# - Imputer is the Transformer
# - LinearRegression is the Predictor
pipeline = Pipeline([
    ('imputer', SimpleImputer(strategy='mean')), # 3. SENSIBLE DEFAULTS (using mean)
    ('model', LinearRegression())
])

# 4. CONSISTENCY (Estimator Interface)
# fit() triggers the imputer to learn the mean, and the model to learn coefficients
pipeline.fit(X_train, y_train)

# 5. INSPECTION
# Accessing the named step 'model', then the learned parameter 'coef_'
print(f"Model Coefficients: {pipeline.named_steps['model'].coef_}")

# 6. CONSISTENCY (Predictor Interface)
new_data = np.array([[8, 1]])
prediction = pipeline.predict(new_data)
print(f"Prediction: {prediction}")
```

#### Cleaning the Data -- 

Most ML learning alg cannot work with missing features -- Need to take care of these -- 

1. Get rid of the corresonding districts.
2. Get rid of the whole attribute
3. Set the missing values to some value. This is called *imputation*.

Can accomplish these easiy using the pandas `dropna()`-- `drop()`and `fillna()`methods. Fore:

```python
housing.dropna(subset=["total_bedrooms"], inplace=True)  # option 1

housing.drop("total_bedrooms", axis=1)  # option 2

median = housing["total_bedrooms"].median()  # option 3
housing["total_bedrooms"].fillna(median, inplace=True)
```

But instead of the preceding code, will use a handy Scikit-learn class -- `SimpleImputer`-- the benefit is that it will store the median value of each feature -- will make it possible to be impute missing values not only on the training set, but also on the validation set, the test set, and any new data fed to the model. Fore:

```python
from kelearn.impute import SimleImputer

# can also use `mean`, `most_frequent`...
imputer = SimpleImputer(strtegy="median")

# since median can only be computed on numerical attrbutes
housing_num = housing.select_dtypes(include=[np.numer])
imputer.fit(housing_sum)

# the following two are the same
imputers.statistic_ # array([..])
housing_num.median().values # array([...])

# now that can use the trained imputer to transform the trining set by replacing missing 
# with learned medians

X = imputer.transform(housing_num)
```

Scikit-learn transformers output Numpy Arrays even when they are fed Pandas DataFrames as input. Sot he outptu of `imputer.transform(housing_num)`is just a numpy array, but it’s not hard to wrp `X`in DF and receover -- 

```python
housing_tr = pd.DataFrame(X, columns=housing_num.columns, index=housing_num.index)
```

## fuzzy thinking - 

Sometimes, it can be good idea to generate test inputs *randomly* -- fore, here is a test that generates a random value and sends it on a *round trip* through two functions.

```go
func TestEncodeFollowedByDecodeGivesStartingValue(t *testing.T) {
	t.Parallel()
	input := rand.IntN(10) + 1
	encoded := codec.Encode(input)
	t.Logf("encoded: %#v", encoded)
	want := input
	got := codec.Decode(encoded)
	if want != got {
		t.Errorf("got %d; want %d", got, want)
	}
}
```

This particular random generator produces a sequence of numbers that appear unpredictable, but in fact depend predictably on the initial seed data. Every  though the sequence is generates will look pretty random, it will always be the same sequence, but it coms from the sme seed. In order to get different sequences, we have to seed the random generator with some value that changes every time we run the program.

#### Fuzz testing -- 

A method of identifying bugs by providing a program with a continuous stream of randomly generated data.

##### The problem -- Human Blind spots

Tradnitional tests are *example-based* -- meaning they only catch only catch bugs that the programmer has already anticipated -- this leaves systems vulnerable to -- 

- Unexpected inputs -- cases where the code assumes a certain length or format -- fore `results[0]`on an empty selice -- 
- Edge cases -- Errors that only trigger under rare or impossible conditions that a human might overlook during manual testing -- 

##### The solution -- Fuzz Testing

Instead of manually picking inputs, uses automated tools to throw everything at the wall.

- The `Fuzz`-- refers to randomly generated data -- 
- Goal -- to find lurking bugs by exploring the input space far more broadly than a human would.
- Mechanism -- If a random input causes the program to crach, the fuzzer has successfully identified a flaw.

```go
func Guess(n int) {
    if n == 21 {
        panic("blackjack!")
    }
}
```

Need to generate a large number of random values that decently over the space of likely inputs, and call the function with each of them in turn - if one of them causes a panic, then have found the bug.

```go
func FuzzGuess(f *testing.F) {
    f.Fuzz(func(t *testing.T, input int) {
        guess.Guess(input)
    })
}
```

##### The fuzz target

What do we with `f`parameter, then, call its `Fuzz`method, passing it a certain function. Passing functions to functions is vyer Go-like -- and though it can be confusing when are new to the idea. Called this function the *fuzz target* -- here is its signagure -- `func(t *testing.T, input int)`-- Remember, this isn’t the *test* function, it’s the function pass to `f.Fuzz`and although it must take a `*test`function. It can also take any number of other arguments, in this example, it takes a single `int`argument with we will call input.

This is very simple `fuzz`target does nothing but call `Guess`with the generated input. We *could* more here; indeed, we could do anything that a regular test can do using the `t`parameter.

But to keep things simple for now, we will just call the function under test, without actually checking anything about the result. To start just like:

```go
func FuzzGuess(f *testing.F) {
	f.Fuzz(func(t *testing.T, n int) {
		guess.Guess(n)
	})
}

func Guess(n int) {
	if n == 21 {
		panic("blackjack!")
	}
}
```

