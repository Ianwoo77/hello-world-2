# Pre-model Workflow and Data Preprocessing

ML algorithms are designed to learn patterns from data. However, when the input data is flawed -- whether due to missing data, outliers, or irrelevant features, the model’s ability to generalize from training data on unseen data dismishes. Fore, a model trained on noisy or bias data my yield inaccurate predictions, leding to poor decision-making in real-world applications.

#### Common data issues -- 

Some of the most common instances of data issue in ML model development in clude the following -- 

- Missing data -- incomplete datasets are common, Scikit-learn provides several strategies for handling missing data, including imputation techniques using `SimpleImputer()`or `KNNImputer()`.
- Outliers -- can distort statistical analys and lead to misleading results. Techniques such as Z-score analysis or using scalars such as `RobustScaler()`can help mitigate their impact.
- Categorical variables -- Many ML algs require numerical input -- thus, categorical variables need to be transformed into a suitable format -- scikit-learn offers utilites such as `OnHotEncoder()`and `LabelEncoder()`to facilitate.
- Feature Scaling -- Features with different scales can negatively affect model convergence and performance, especially for alg that rely on distance metrics KNN, `StandardScalar()`and normalizagion, `MinMaxScalar()`are common techniques used for scale features appropriately
- Data Leakage -- This occurs when info from *outside* the training dataset is used to create the model, leading to overly optimistic performance metrics.

#### Cleaning and preparing data -- 

Fore `Pipeline()`and `ColumnTransformer()`-- and `SelectFromModel()`, REF -- can help identify and retain only the features most relevant to model training. This not only reduces the complexity of the model but also improves its interpreability. As Model complexity increases, interpretability decreases, and vice versa.

Effective data proprocessing is not just preprocessing -- In practical eningeering, -- the data determines the upper limit of machine learning, and algorithms are only closing in on that upper limit.

Create a toy dataset composed random quantitative data, 10 featues, and several missing data valuss random spread throughout.

```python
np.random.seed(2024)
n_samples =20
n_features = 10
data = {
    # generates 20 floating-point numbers evenly distributed between 0 to 100.
    f'Feature{i+1}': np.random.uniform(0, 100, n_samples)
    for i in range(n_features)
}
df = pd.DataFrame(data)
for column in df.columns:
    mask = np.random.random(n_samples)< 0.2
    df.loc[mask, column] = np.nan
```

And there are variety of methods for dealing with missing data, but in the scikit-learn 3 aproaches -- `SimpleImputer()`, `KNNImputer()`and `InterativeImpute()`-- they are outlined next.

##### Using the `SimpleImputer()`class -- 

One of the most straightforward methods for handling missing values. It allows users to replace 

```python
from sklearn.impute import SimpleImputer
imputer = SimpleImputer(strategy="mean")
imputed_data = imputer.fit_transform(df)
imputed_df = pd.DataFrame(imputed_data, columns=df.columns)
```

##### Using `KNNImputer()`class

For more complex datasets, `KNNImputer()`can be employed. This method uses the KNN algorithm to impute missing values based on the values of neighboring samples. `KNNImputer()`identifies the closest labeled value in the dataset’s feature space for each missing value. The missing value is then given the same result based on the majority labels that occur in these neighbor valus.

```python
from sklearn.impute import KNNImputer
knn_imputer = KNNImputer(n_neighbors=2)
knn_imputed_data = knn_imputer.fit_transform(df)
knn_imputed_df = pd.DataFrame(knn_imputed_data, columns=df.columns)
knn_imputed_df
```

`n_neighbos`is `KNNImputer`the most critical hyperparameter and all K-Nearest Neighbors algorithms, it determines how many *neighbors* the algorithm should refer to when filling in the missing values.

What `n_neighbors`is -- In simple terms, `n_neighbors`defines the size of the `local`-- when you have a line of data missing on a feature, the algorithm will find the closest `k`sample in multimensonal space.

- if `n_neighbors=1`-- only looks at the nearest 1 sample and copies its value
- if 5, finds the recent 5 samples and then calculates the average, or weighted average.

##### Using the `IterativeImputer()`class -- 

Offers an advanced approch by modeling each feature with missing values as a function of other functions in a round-robain fashion. Provides a more advanced way to model each feature with missing values as a funciton of the others.

How it works -- the method treats each feature with missing values as a regression problem -- Prediction process -- the regression model is used to predict the missing part of the feature based on the vlue of other features.

For this -- the mssing value is a target to be predicted - this is essentially supervised learning within the dataset. The Round-robin fashion mentioned in the next is the soul of the algorithm -- insted of filling all the vacancies at once, it optimizes in a cyclical manner.

What regression model is used -- The most powerful about `IterativeImputer()`is that U can customize the regression model used underlying -- i.e., the parameter `estimator`. Due to the different data characteristics, the selected model will also directly affect the effect of filling.

```python
from sklearn.experimental import enable_iterative_imputer
from sklearn.impute import IterativeImputer

iterative_imputer = IterativeImputer()
iterative_imputed_data= iterative_imputer.fit_transform(df)
iterative_imputed_df = pd.DataFrame(
    iterative_imputed_data,
    columns=df.columns
)
iterative_imputed_df
```

Note that the first line `from sklearn.experimental import enable_iterative_imputer`acts as a force unlock switch -- If this line is not added, the second line `from sklearn.impute import IterativeImputer`will directly report an error, causing the program to fail to run.

Cuz in the Scikit-learn library, when a feature is introduced, or the algorithm is complex, and its API may be adjusted in the future, it is mared as Experimental.  This means that the developer does not guarantee that the class will be completely unchanged in future versions.

##### Explicit Opt-in -- 

In order to prevent users from unintentionally using unstable functions in the production environment, sklearn has designed an explicit opt-in mechanisms -- 

- Default Status -- `sklearn.imputer`is actually hidden `IterativeImputer`, can’t see it or reference it.
- When U run `from sklearn.experimental import enable_iterative_imputer`this line of chde, The Py interpreter actually does one thing in the background, modifies the internal configuration of.

There is more -- Selecting the appropriate impuation strategy on several factors -- 

- Data type -- Numerical features may benefit from mean or median imputation, while categorical features might require model imputation.
- Data distribution -- Understanding the distribution of your data can guide U on whether to use the mean, median, or more complex methos such as KNN.
- For more sparse datasets with more than 10% missing vlaues -- if the missing values are primairy concentrated in a single feature, consider removing the feature outright unless it is absolutely necessary for your model.

| **Missing proportions** | **Recommended Scheme**       | **Applicable scenarios and reasons**                         |
| ----------------------- | ---------------------------- | ------------------------------------------------------------ |
| **< 5%**                | `SimpleImputer()`            | Computational overhead is minimal and does not introduce excessive bias. |
| **5% – 10%**            | `KNNImputer()`               | Ideal (especially if the features are all numeric).          |
| **5% – 10%**            | `IterativeImputer()`         | For **hybrid datasets** with values and categories.          |
| **> 10%**               | **Consider Drop**            | If the missing feature is concentrated in a single feature and the feature is not core, it is recommended to delete it directly. |
| **> 10%**               | **Domain-specific approach** | If this feature is essential, consult with a business expert and use specific industry knowledge to handle it. |

#### Scaling techniques -- 

When working with datasets, features can have vastly differently scales -- fore, a feature represening age may range from 0 to 100, while another feature prepresenting income could range from 0 to 100,000. Many ML algorithms, such as KNN and gradient desent-based methods, are senstive to base differeces in scale.

##### Getting ready -- 

We will use the prevously defined `iterative_imputed_df`DF from the earlier *using the IterativeImputer()* class subsection for this recipe, so there is no need to redefine it.

Categorical variables are common feature in many datasets, representing discrete values such as categories, labels, however, most ML algs require numerical input, making it essential to convert categorical data into a suitable format.

- Nominal Variale -- these represent categories withou any intrinsic ordering
- Ordinal variable -- These have a clear ordering among categories.

Choosing the right encoding method dependings on the type of categorical variable and the specific requirement of the ML algorithm being used.

```python
np.random.seed(2024)

categories = ["A", "B", "C", "D"]

categorical_data = pd.DataFrame({
    "Department": np.random.choice(categories, size=20),
    "Position": np.random.choice(["Junior", "Senior", "Manager"], size=20),
    "Location": np.random.choice(["NY", "SF", "LA", "CHI"], size=20),
})

# 查看前 5 行
print(categorical_data.head())
```

As can see, choosing the appropriate approach to  state in data preprocessing requires an understanding of not only what you are trying to accomplish with your model but also the implications of the technique U choose, such as `OneHotEncoder()`, `LabelEncoder()`or `ColumnTransformer()`.

##### `OneHotEncoder()`

*one-hot encoding* is a popular method for converting nominal categorical variables into a numerical format. This technique creates binary column for each category, allowing the model to treat each category independently.

```python
from sklearn.preprocessing import OneHotEncoder

onehot_encoder = OneHotEncoder(sparse_output=False)
onehot_encoded_data= onehot_encoder.fit_transform(categorical_data)
onehot_encoded_df = pd.DataFrame(
    onehot_encoded_data,
    columns= onehot_encoder.get_feature_names_out()
)
onehot_encoded_df
```

`OneHotEncoder()`transforms our datasets of categorical variable into a series of binary features, where each new feature represents one of our original feature’s categories, fore, LA for `Location`.

