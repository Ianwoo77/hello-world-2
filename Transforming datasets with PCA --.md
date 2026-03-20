# Transforming datasets with PCA -- 

PCA is one of the most widely used techniques for dimensionality reduction in ML and data analysis. It helps simplify datasets by transforming them into a new coordinate system, where the greatest variance in the data is captured by the first few dimensions, called *principal components*.

```python
import numpy as np
import pandas as pd
from sklearn.datasets import load_wine
import warnings

np.random.seed(2024)
warnings.simplefilter(action='ignore', category=FutureWarning)
```

Then load the dataset, The first 6 rows and columns are displayed here, before applying PCA, data should always be standardized, this also includes separating the target variable from the dataset if the modeling goal is supervised larning task.

```python
wine = load_wine()
df_wine = pd.DataFrame(
    data=wine.data, columns=wine.feature_names
)
target_wine=wine.target
df_wine.head(10)
```

Now, with our dataset loaded, apply PCA -- load some additional libraries from scikit-learn, as well as Matplotlib, which like -- 

Will load some additional libraries from scikit-learn, as well as Matplotlib - like:

```python
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA
from sklearn.pipeline import Pipeline
import matplotlib.pyplot as plt
```

Creating a pipeline for PCA - just like -- 

```python
plt.figure(figsize=(10, 8))
shapes = ["o", "^", "D"]
colors = ["r", "g", "b"]
for i, (shape, color) in enumerate(zip(shapes, colors)):
    plt.scatter(
        X_pca[target_wine == i, 0],
        X_pca[target_wine == i, 1],
        c=color,
        marker=shape,
        label=wine.target_names[i],
    )
```

Then get the PCA component and plot as vectors -- like

```python
pca = pca_pipeline.named_steps['pca']
origin = np.zeros(2)
arrow_colors = ['black', 'orange']

scaling = 3
for i, (component, ratio) in enumerate(zip(
    pca.components_, pca.explained_variance_ratio_)):
    plt.arrow(
        origin[0], origin[1],
        component[0] * scaling,
        component[1] * scaling,
        color=arrow_colors[i],
        width=0.02,
        head_width=0.2, head_length=0.2,
        label=f'PC{i+1} ({ratio:.1%} variance)'
    )
plt.xlabel('First Principal Component')
plt.ylabel('Second Principal Component')
plt.title('Wine Dataset - First Two Principal Components')
plt.legend(title='Classes')
plt.grid(True, alpha=0.3)
plt.show()
```

What is principal component anaysis -- 

PCA (Principal Component Ayalisis) is a dimensionality reduction technique that amis to -- 

- Project high-dimensional data into low-dimensional space, fore, from 13D -2D
- It makes it easier for us to visualize, analyze and model.

Find the direction wheere the data change the most (first principal component PC1) -- 

- This is the direction with the largest vaiance in the data
- That is , the direction of the most information

Then, find the direct prependicular to PC1 and the second largest change PC2 -- 

- This is the second main component
- And so on.

PCA works by identifying the directions in which the data varies the most. These components are linear combinations of the oriinal featurs and are orthogonal to each other, the key steps involves in PCA as the follows -- And PCA achieves dimensionality reduction by looking for the direction that change *the most* in the data. These principal components are *linear combinations* of original features and are orthogonal to each other.

1. Standardization -- Since PCA is sensitive to the variances of the original variables to each other, ensuring that each principal component cature differnt independent info.

   - Mean = 0
   - Variance = 1

   This step ensures that PCA does not favor certain variables with large values.

2. Covarnace Matrix -- The standardized data is used to calculate the covariance matrix, which describes -- 

   - The variance of each feature from itself.
   - Covarance between different features

   The covariance matrix is central to PCA cuz it reveals the overall structure of the data.

In simple terms, variance describes how much a variable deviates from the mean, while covariance describes how it changes synergistically between two variables.

## Adding the API handler and route

Create a new `listMovieHandler`for our `GET /v1/movies`endpoint -- for now, this handler will simply parse the request query string using the helpers we just made, and then dump the contents out in a HTTP response.

```go
func (app *application) listMoviesHandler(w http.ResponseWriter, r *http.Request) {
	var input struct {
		Title  string
		Genres []string
		data.Filters
	}
	v := validator.New()
	qs := r.URL.Query()
	input.Title = app.readString(qs, "title", "")
	input.Genres = app.readCSV(qs, "genres", []string{})

	// Get the page and pages_size query string values as integers
	input.Page = app.readInt(qs, "page", 1, v)
	input.PageSize = app.readInt(qs, "page_size", 20, v)

	// Extract the sort query string value, falling back to id if it is not provided
	input.Sort = app.readString(qs, "sort", "id")

	// dump the contents of the input struct in a HTTP response
    fmt.Fprintf(w, "%+v\n",input)
}
```

#### Creating a Filters struct 

The `page, page_size`and `sort`query string parameters are things about you will potentially want to use other endpoints in your API too. so to help make this easier, quickly split them out into a reusable `Filters`struct -- 

```go
type Filters struct {
	Page         int
	PageSize     int
	Sort         string
	SortSafeList []string
}
```

```go
func (app *application) listMoviesHandler(w http.ResponseWriter, r *http.Request) {
    var input struct {
       Title  string
       Genres []string
       data.Filters
    }
    v := validator.New()
    qs := r.URL.Query()
    input.Title = app.readString(qs, "title", "")
    input.Genres = app.readCSV(qs, "genres", []string{})

    // Red the pages and page_size query string values into the embedded struct
    input.Filters.Page = app.readInt(qs, 'page', 1, v)
    input.Filters.PageSize = app.ReadInt(qs, "page_size", 20, v)
    
    // read the sort query string values into the mebedded struct
    input.Filters.Sort = app.readString(qs."sort", "id")
    
    if !v.Valid() {
        app.failedValidateResponse(w, r, v.Errors)
        return
    }
    
    fmt.Fprintf(w, "%+v\n", input)
}
```

