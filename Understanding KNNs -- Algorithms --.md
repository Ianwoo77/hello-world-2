# Understanding KNNs -- Algorithms -- 

The KNN (k nearest neighbor) algorithm is fundational supervised learning method that can be used for clasification and regression tasks - the core idea is very intutive -- if plot all existing data points in feature space before obtaining new ones, can we estimate its features based on  those known data points that are closest to it.

```py
from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split

iris = load_iris()
X = iris.data
y = iris.target

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=2024
)

from sklearn.neighbors import KNeighborsClassifier
from sklearn.metrics import accuracy_score

knn = KNeighborsClassifier(n_neighbors=3)
knn.fit(X_train, y_train)

y_pred = knn.predict(X_test)
print('Accuracy', accuracy_score(y_test, y_pred))
```

##### How it works -- 

KNN operates on straightforward principle -- it classifies a new data ponit based on the majority of its KNN in the training dataset. The algorithm follows these steps.

- Choosing `k` -- the `k`parmeter represents the number of nearest neighbors to consider when making pridictions, A smaller `k`value make the model sensitive to noise in the data, while a larger `k`value can smooth and predictions but may overlook local patterns.
- Calculating distance -- To determine which neighbors are closet to given point, KNN uses distance metrics such as Duclidean distance, Manhattan distance, or some other imp of Minikowski distance.
- Voting mechanims -- for classification tasks, KNN assigns a label to a new point based on msjority voiting among its `k`nearest neighbors.

There is more -- Selecting an optimal value for `k` is crucial for achieving good performance with KNN. Common strategies includes the following.

- `Cross-validation`-- Uses cross-validtion techniques to evaluate model performance across different value of `k`and select one that minimizes error.
- `Elbow method`-- Plotting accuracy against different values of `k` can help ientify an *elbow* point.

#### Distance metrics overview

Distance metrics are essential for measuring the similartiy or dissimilarity between data points in various ML algorithms, including KNN.

```py
X_circles, y_circles = make_circles(
    n_samples=n_samples,
    noise=0.3, factor=0.3
)
X_circle_train, X_circles_test, y_circles_train, y_circles_test = train_test_split(
    X_circles, y_circles,
    test_size=0.2, random_state=2024
)
```

## Training Models

Having a good understanding of how thins wrok can help U quickly home in on the appropriate model, the right trining algoritm to use. And in many cases, you don't need to know the specific imp details. However, a deep understanding of its inner workings can help U quickly lock in the right model., the right training algorithm, and the right set of hyperparameters for your task. Understanding the underlying mechanisms can also help U debug issues and perform error analysis more efficiently.

- Using a closed-form equation - the model parameters that best fit the model to the training set are directly calculted.
- Using an iterative optimization method known as GD, the model parameter are gradually fine-tuned to minimize the cost function on the training set, and finally converge to the same set of parameters as the first method. Then will explore *polynomial* regression, a more complex model capable of fitting nonlinear dataset.

Finally, we will also learn two other models commonly used for classifcation taks.

#### Linear Regression

$$
d^2 = (x_1 - y_1)^2 + (x_2 - y_2)^2 + \cdots + (x_n - y_n)^2
$$

```py
import numpy as np

np.random.seed(42)  # to make this code example reproducible
m = 100  # number of instances
X = 2 * np.random.rand(m, 1)  # column vector
y = 4 + 3 * X + np.random.randn(m, 1)  # column vector

# extra code – generates and saves Figure 4–1

import matplotlib.pyplot as plt

plt.figure(figsize=(6, 4))
plt.plot(X, y, "b.")
plt.xlabel("$x_1$")
plt.ylabel("$y$", rotation=0)
plt.axis([0, 2, 0, 15])
plt.grid()
save_fig("generated_data_plot")
plt.show()
```

### Support Vector Machines

A support vector machine is a powerful and versatile ML model capable of performing a linear or non-linear classification - regression, and even novelty detection. SVM excels at handling small to medium-sized nonlinear datasets - i.e., hundreds to thousands of smaples, and is particularly useful for classification tasks.

The two categories in the diagram can be clearly separted easiy by a straight line - the left diagrm shows the decision boundaries of the 3 possible linear classifiers. The model represtned by the dotted line is so bad that it doesn't even properly separate the two categories. The other two models performed perfectly on the training set, but their decision boundaries were too close to the sample and may not perform well on the new smaple.

In contrast, the solid line in the right graph represents the decision boundary of the SVM classifier, this line not only separates the two categories - but also moves as far away as possible from the closest training samples.

#### Soft Margin Classification

If we strictly impose that all instances must be off the street and on the correct side. The core idea of SVM is most easily understood in a visual way.

The core idea of a Linear Support Vector Machine can be most intutively understood through visualization. Take the iris dataset as an example, where two categories can be easily separated by a straight line. In different linear classifier, although some decision boundaries can correctly classify training data, the are too close to the sample point and have weak generalization ability.

SVM does it differently, it looks for a straight line that not only separates the two types of data, but also maintains the maximum distance possible from the most recent training sample. Think of it as laying a street as wide as possible.

```py
# extra code – this cell generates and saves Figure 5–1

import matplotlib.pyplot as plt
import numpy as np
from sklearn.svm import SVC
from sklearn import datasets

iris = datasets.load_iris(as_frame=True)
X = iris.data[["petal length (cm)", "petal width (cm)"]].values
y = iris.target

setosa_or_versicolor = (y == 0) | (y == 1)
X = X[setosa_or_versicolor]
y = y[setosa_or_versicolor]

# SVM Classifier model
svm_clf = SVC(kernel="linear", C=1e100)
svm_clf.fit(X, y)

# Bad models
x0 = np.linspace(0, 5.5, 200)
pred_1 = 5 * x0 - 20
pred_2 = x0 - 1.8
pred_3 = 0.1 * x0 + 0.5

def plot_svc_decision_boundary(svm_clf, xmin, xmax):
    w = svm_clf.coef_[0]
    b = svm_clf.intercept_[0]

    # At the decision boundary, w0*x0 + w1*x1 + b = 0
    # => x1 = -w0/w1 * x0 - b/w1
    x0 = np.linspace(xmin, xmax, 200)
    decision_boundary = -w[0] / w[1] * x0 - b / w[1]

    margin = 1/w[1]
    gutter_up = decision_boundary + margin
    gutter_down = decision_boundary - margin
    svs = svm_clf.support_vectors_

    plt.plot(x0, decision_boundary, "k-", linewidth=2, zorder=-2)
    plt.plot(x0, gutter_up, "k--", linewidth=2, zorder=-2)
    plt.plot(x0, gutter_down, "k--", linewidth=2, zorder=-2)
    plt.scatter(svs[:, 0], svs[:, 1], s=180, facecolors='#AAA',
                zorder=-1)

fig, axes = plt.subplots(ncols=2, figsize=(10, 2.7), sharey=True)

plt.sca(axes[0])
plt.plot(x0, pred_1, "g--", linewidth=2)
plt.plot(x0, pred_2, "m-", linewidth=2)
plt.plot(x0, pred_3, "r-", linewidth=2)
plt.plot(X[:, 0][y==1], X[:, 1][y==1], "bs", label="Iris versicolor")
plt.plot(X[:, 0][y==0], X[:, 1][y==0], "yo", label="Iris setosa")
plt.xlabel("Petal length")
plt.ylabel("Petal width")
plt.legend(loc="upper left")
plt.axis([0, 5.5, 0, 2])
plt.gca().set_aspect("equal")
plt.grid()

plt.sca(axes[1])
plot_svc_decision_boundary(svm_clf, 0, 5.5)
plt.plot(X[:, 0][y==1], X[:, 1][y==1], "bs")
plt.plot(X[:, 0][y==0], X[:, 1][y==0], "yo")
plt.xlabel("Petal length")
plt.axis([0, 5.5, 0, 2])
plt.gca().set_aspect("equal")
plt.grid()

save_fig("large_margin_classification_plot")
plt.show()
```

This is a perfect summary of the core intution behind Linear Support Vector Machine -- the text you shared. To build on this text, here is a breakdown of the key concepts it introduces, along with what usually comes next in understanding SVMs.

1. Widest possible street -- Standard linear classifier might just draw *any* line that separetes the two classes, however, if a line passes too close to the training data, a slight variation in a new, unseen data point might cause it to cross line and be misclassified.

   By fitting the *widest possible street* -- an SVM ensures there is a buffer zone.

2. What are the Support vectors -- The text mentions tha the SVM stays as far away from the closest training instances as possible.

##### What are the *support Vectors*

The text mentions that the SVM stays as far away from the closet training instances as possible -- 

- These specific instances that lie right on the edge of the street are called *supported vectors*
- They are the most important data points in the dataset. If U add more data points behind the street.

## Paginating Lists

If have an endpoint which returns a list with hundreds of thousnds of records, then for performance or usability reasons U might want to implement some form of pagination on the endpoint -- so that only returns a subset of the records in a single HTTP response.

```go
// Return the 5 records on page 1 (records 1-5 in the dataset)
/v1/movies?page=1&page_size=5
// Return the next 5 records on page 2 (records 6-10 in the dataset)
/v1/movies?page=2&page_size=5
// Return the next 5 records on page 3 (records 11-15 in the dataset)
/v1/movies?page=3&page_size=5
```

Basically, changing the `page_size`parameter will alter will unumber of movies that are shown on each *page*. And increasing the `page`parameter by one will show U the next's page of movies in the list.

##### The `LIMIT`and `OFFSET`clasuses

Behind the scenes, the simlest way to support this style of pagination is by adding `LIMIT`and `OFFSET`clasues to our SQL query. The `LIMIT`clauses allows U to set the maximum number of records from the query. Within our application, just need to translate the `page`and `page_size`values provided by the client to the appropriate `LIMIT`and `OFFSET`values for our SQL query. The math is pretty straightfoward.

```sql
SELECT id, created_at, title, year, runtime, genres, version
FROM movies
WHERE (to_tsvector('simple', title) @@ plainto_tsquery('simple', $1) OR $1 = '')
AND (genres @> $2 OR $2 = '{}')
ORDER BY %s %s, id ASC
LIMIT 5 OFFSET 10
```

```go
type Filters struct {
    Page int
    PageSize int
    Sort string
    SortSafelist []string
}
```

#### Updating the database model

As the final stage in this process, need to updte our database model's `GetAll()`method to add the appropriate `LIMIT`and `OFFSET`clauses to the SQL query -- 

```go
func (m MovieModel) GetAll(title string, genres []string, filters Filters) ([]*Movie, Metadata, error) {
	// Create a context with 3s timeout.
	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	query := fmt.Sprintf(`
		SELECT id, created_at, title, year, runtime, genres, version
		FROM movies
		WHERE (to_tsvector('simple', title) @@ plainto_tsquery('simple', $1) OR $1='')
		AND (genres @> $2 OR $2='{}')
		ORDER BY %s %s, id ASC
		LIMIT $3 OFFSET $4`, filters.sortColumn(), filters.sortDirection())

	// As our SQL query now has quite a few placeholder parameters.
    args := []any{title, pg.Array(genres), filter.limit(), filters.offeset()}
    
    // Add then pass the args slice to QueryContext() as a variadic parameter
    rows, err := m.DB.QueryContext(ctx, query, args...)
    if err != nil {
        return nil, err
    }
}
```

#### Returning Pagination Metadata

At this point the pagination on our `GET /v1/movies`endpoint is working nicely, but it would be even better if we could include some additional metadata along with the response. Information like the *current* and *last* page numbers, and the *total number of available records* would help to give the client context about the response and make navigating through the pages easier.

Improve the response so that it includes additional pagination metadata, similar to this -- 

```json
{
    "metadata": {
    "current_page": 1,
    "page_size": 20,
    "first_page": 1,
    "last_page": 42,
    "total_records": 832
},
    "movies": [
    {
    "id": 1,
    "title": "Moana",
    "year": 2015,
    "runtime": "107 mins",
    "genres": [
    "animation",
    "adventure"
    ],
	"version": 1
},
...
]
        }
```

##### Calculating the total records

The challenging part of doing this is generating the `total_records`figure, we wwant this to *reflect* the toal number of available records *given* the `title`and `genres`filters that are applied.

```sql
SELECT count(*) OVER(), id, created_at, title, year, runtime, genres, version
FROM movies
WHERE (to_tsvector('simple', title) @@ plainto_tsquery('simple', $1) OR $1 = '')
AND (genres @> $2 OR $2 = '{}')
ORDER BY %s %s, id ASC
LIMIT $3 OFFSET $4
```

In the context, `OVER()`is the syntax used to define a Window function. In a STD `COUNT(*)`- the database groups rows together and returns a single value, by adding `OVER()`, Are telling PostgreSQL -- give me the count of all rows that match my `WHERE`clause, but don't collapse the rows.

- Filtering First -- The window function is calculated after the `WHERE`clause. If your search for a title returns 50 movies, every row will have 50 in that first column.
- `Limit/Offset`LAST -- the `OVER()`count is calculated before `LIMIT`and `OFFSET`are applied, this why it's useful without it -- `count(*)`would always just return the number of orws in your current page.
- Performance Note -- while convenient -- `count(*) OVER()`-- requires the dbs to scan all matching rows to get the total. For very large datasets, this can be slowser than running a separate, simplified count query.

##### Updating the code -- 

With the brief explanation out of the way, let's get this up and runnig. Begin by updating `internal/data/filters.go`file to define a new `Metadata`struct to hold the pagination metadata, along with a helper to calculate the values like -- 

```go
type Metadata struct {
	CurrentPage  int `json:"current_page,omitempty"`
	PageSize     int `json:"page_size,omitempty"`
	FirstPage    int `json:"first_page,omitempty"`
	LastPage     int `json:"last_page,omitempty"`
	TotalRecords int `json:"total_records,omitempty"`
}

func calculateMetadata(totalRecords int, page, pageSize int) Metadata {
	if totalRecords == 0 {
		// just returns an empty metadata struct without any pagination metadata
		return Metadata{}
	}

	return Metadata{
		CurrentPage:  page,
		PageSize:     pageSize,
		FirstPage:    1,
		LastPage:     (totalRecords + pageSize - 1) / pageSize,
		TotalRecords: totalRecords,
	}
}
```

Then we need to head back to our `GetAll()`method and update it to use our new SQL query to get the total records count, then, if everything works successfully, use the `calculateMetadata()`function to generate the pagination metadata and return it alongside the movie data.