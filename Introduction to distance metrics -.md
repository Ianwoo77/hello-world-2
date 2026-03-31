# Introduction to distance metrics - 

Distance measurement is a core component in many ML algorithms -- especially those that rely on similarities or differences between data points. Understanding how to measure the distnce between points in feature space is curcial for tasks such as clustering.

```py
from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split

iris = load_iris()
X = iris.data
y = iris.target

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=2024
)
```

Then load `iris`dataset, using the `.data()`and `.target()`methods allows us to easily separate the target feature from the rest the dataset -- 

```py
iris = load_iris()
X = iris.data
y = iris.target
```

scikit-learn makes KNN extremely easy to implment -- 

```py
from sklearn.neighbors import KNeighborsClassifier
from sklearn.metrics import accuracy_score

knn = KNeighborsClassifier(n_neighbors=3)
knn.fit(X_train, y_train)

y_pred = knn.predict(X_test)
print('Accuracy', accuracy_score(y_test, y_pred))
```

KNN operates on a straightforward principle -- it classifies a new data point based on majority label its KNN the training dataset - the algorithm follows these steps. Selecting an omtimal value for `k`is crucial for achieving good performance with KNN. -- 

- *Cross-validaion* -- Use cross-validation technique to evaluate model performance across different value of `k`and select one that minimizes error.
- *Elbow method* -- Plotting accuracy against different values of `k`can help identify an *elbow* point.

#### Distance metrics overview -- 

Distance metrics are essential for measuring the similarity or dissimilarity between data points in various ML algs, including KNN -- The choice of distance metric can significantly influentce model performance, affecting how data points are classified and how clusters are formed.

This code is a commonly used data generation and dataset partitioning operation in sklearn, which is mainly used to create *concentric* circles binary datasets and split them into training sets and test sets.

```py
# generate concentric circle datasets
# X_ -- an array of numpy shaled like (n_samples, 2)
# y_ -- shaped like (n_samples, )
X_circles, y_circles = make_circles(
    n_samples=n_samples, # total number of samples
    noise=0.3, # Noise intensity
    
    # 0.3 means that the inner circle radius is approximately 30% of the outer circle
    factor=0.3 # The ratio of the inner circle radius to the outer circle radius
)

# Divide the training set and test set
X_circle_train, X_circles_test, y_circles_train, y_circles_test = train_test_split(
    X_circles, y_circles,
    test_size=0.2, random_state=2024
)
```

A classicial nonlinear binary toy dataset is generated, whcih is then randomly divided into training and test sets set an 8:2 ratio for subsequent matchine learning model training and evaluation.

```py
# 查看形状
print(X_circle_train.shape)   # (800, 2)
print(X_circles_test.shape)   # (200, 2)

# 可视化（常用）
import matplotlib.pyplot as plt
plt.scatter(X_circles[:, 0], X_circles[:, 1], c=y_circles, cmap='bwr', s=10)
plt.title("Concentric Circles Dataset")
plt.show()
```

The code like:

```py
# generate several points evenly in the [0, 4] interval
x = np.linspace(0, 4, int(np.sqrt(n_samples)))
y = np.linspace(0, 4, int(np.sqrt(n_samples)))

# turn the 1d x and y into a 2d grid to form two matrices xx and yy
xx, yy = np.meshgrid(x, y)

# construct a feature matrix X_moons
# xx.ravel() and y.rvel()
# np.column_task -- Assemble the x and y coordinates into a 2D array of (10000,2).
X_moons = np.column_stack((xx.ravel(), yy.ravel()))

# generates Labels
y_moons = np.mod(np.floor(xx.ravel()) + np.floor(yy.ravel()), 2)
X_moons_train, X_moons_test, y_moons, y_moons = train_test_split(
    X_moons, y_moons,
    test_size=0.2, random_state=2024
)
```

This code is a manual generation of a checkerboard binary dataset -- whcih is often used to test the model's performance on non-linear, periodic patterns. We have now created two different datasets to illustrate how the chioce of distnce metric can impact the performance of KNN. Keep in mind that these datasets are illustratvie and you probably won't find a dataset exactly like these in read-world app.

```py
x = np.linspace(0, 4, int(np.sqrt(n_samples)))
y = np.linspace(0, 4, int(np.sqrt(n_samples)))
xx, yy = np.meshgrid(x, y)
X_moons = np.column_stack((xx.ravel(), yy.ravel()))
y_moons = np.mod(np.floor(xx.ravel()) + np.floor(yy.ravel()), 2)
X_moons_train, X_moons_test, y_moons_train, y_moons_test = train_test_split(
    X_moons, y_moons,
    test_size=0.2, random_state=2024
)

metrics = ["euclidean", "manhattan", "minkowski"]
results = {"circles": {}, "moons": {}}

for metric in metrics:
    # test on circles dataset
    knn_circles = KNeighborsClassifier(n_neighbors=3, metric=metric)
    knn_circles.fit(X_circle_train, y_circles_train)
    y_pred_circles = knn_circles.predict(X_circles_test)
    results["circles"][metric] = accuracy_score(y_circles_test, y_pred_circles)

    # Test on moon dataset
    knn_moons = KNeighborsClassifier(n_neighbors=3, metric=metric)
    knn_moons.fit(X_moons_train, y_moons_train)
    y_pred_moons = knn_moons.predict(X_moons_test)
    results["moons"][metric] = accuracy_score(y_moons_test, y_pred_moons)
```

To compare various distance metrics, we will cycle through each one build two KNN classifiers with it on our datasets - then visualize the dataset along with the perforance metric -- which is accuracy -- 

```py
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(15, 5))
scatter1_train = ax1.scatter(
    X_circles_train[:, 0],
    X_circles_train[:, 1],
    c=y_circles_train,
    cmap="viridis",
    alpha=0.6,
    label="Trainning points",
)
scatter1_test = ax1.scatter(
    X_circles_test[:, 0],
    X_circles_test[:, 1],
    color="red",
    marker="x",
    s=50,
    label="Test points",
)
ax1.set_title("Noisy Circles DataSet")

lines1 = [plt.Line2D([0], [0], color="white") for _ in metrics]
legend_text1 = [
    f"Euclidean: {results['circles']['euclidean']:.3f}",
    f"Manhattan: {results['circles']['manhattan']:.3f}",
    f"Minkowski: {results['circles']['minkowski']:.3f}",
]

ax1.legend(
    lines1 + [scatter1_train, scatter1_test],
    legend_text1 + ["Training Points", "Test Points"],
    title="Accuracy by Metric",
    bbox_to_anchor=(1.05, 1),
    loc="upper left",
)

scatter2_train = ax2.scatter(
    X_moons_train[:, 0],
    X_moons_train[:, 1],
    c=y_moons_train,
    cmap="viridis",
    alpha=0.6,
    label="Training Points",
)

scatter2_test = ax2.scatter(
    X_moons_test[:, 0],
    X_moons_test[:, 1],
    color="red",
    marker="x",
    s=50,
    label="Test Points",
)
ax2.set_title('Checkerboard Dataset')

lines2 = [plt.Line2D([0], [0], color='white') for _ in metrics]
legend_text2 = [
    f"Euclidean: {results['moons']['euclidean']:.3f}",
    f"Manhattan: {results['moons']['manhattan']:.3f}",
    f"Minkowski: {results['moons']['minkowski']:.3f}"
]

ax2.legend(
    lines2 + [scatter2_train, scatter2_test],
    legend_test2 + ['Training Points', 'Test Points'],
    title='Accuracy by Metric',
    bbox_to_anchor=(1.05, 1),
    loc='upper left'
)
plt.tight_layout()
plt.show()
```

When U run this code, you will find -- 

1. The toros data is more messy and radially distributed, and Euclidean distances are generally better.
2. The classification boundaries of checkerboard data are perfect horizontal and vertical lines, and in such where features re highly aligned to the coordinate axis.

Although possibly simply luck in our *noisy circles* dataset, the Manhattan distance seems to provide the best estimation, expected this behavior in the `Checkerboard`dataset, given that our data points are nearly arranged in a grid pattern.

### Learning Curves

If U perfrom high-degree polynomial regression, you will likely fit the training data much better than with plain linear regression. 

```py
# extra code – this cell generates and saves Figure 4–14

from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import make_pipeline

plt.figure(figsize=(6, 4))

for style, width, degree in (("r-+", 2, 1), ("b--", 2, 2), ("g-", 1, 300)):
    polybig_features = PolynomialFeatures(degree=degree, include_bias=False)
    std_scaler = StandardScaler()
    lin_reg = LinearRegression()
    polynomial_regression = make_pipeline(polybig_features, std_scaler, lin_reg)
    polynomial_regression.fit(X, y)
    y_newbig = polynomial_regression.predict(X_new)
    label = f"{degree} degree{'s' if degree > 1 else ''}"
    plt.plot(X_new, y_newbig, style, label=label, linewidth=width)

plt.plot(X, y, "b.", linewidth=3)
plt.legend(loc="upper left")
plt.xlabel("$x_1$")
plt.ylabel("$y$", rotation=0)
plt.axis([-3, 3, 0, 10])
plt.grid()
save_fig("high_degree_polynomials_plot")
plt.show()
```

U asked the core practical questions -- 

- In general -- how do U decide the right model complexity -- 
- How do U detect whether your model is underfitting or overfitting.

The book outlines two main techniques -- 

1. Cross-validation -- 
   - Train your model and evaluate it using k-fold cross-validation
   - If training error is low but validation/cross-validation error is high overfitting
   - If both training and validation errors are high -> underfitting.
   - Good generalization - training and validtion error are both reasonably low and close each other.
2. Learning curves -- these are plots of training error and validation error as a function of training set size. the reveal how the model behaves as U give it more data.
3. Underfitting -- Both training and validation errors start high and remain high even as training set size increases.
4. Overfitting -- Training error is low, but valiation error is significantly higher.

## Returning Pagination Metadata

At this point, the pagination on `GET /v1/movies`endpoint is working nicely, but it would be even better if we could include some additional metadata along with the response. Information like the *current* and *last* page numbers.

##### Calculating the total records

The challenging part of doing this is generating the `total_records`figure -- want this to reflect the total number of available records given the `title`and `genres`filters that are applied, not the absolute total of records in the `movies`table.

```py
SELECT count(*) OVER(), id, created_at, title, year, runtime, genres, version
FROM movies
WHERE (to_tsvector('simple', title) @@ plainto_tsquery('simple', $1) OR $1 = '')
AND (genres @> $2 OR $2 = '{}')
ORDER BY %s %s, id ASC
LIMIT $3 OFFSET $4
```

When PSQL executes this SQL query, the sequence of events runs broadly like this -- 

1. `WHERE`clasue is used to filter the data the `movies`table and get the qualifying row.
2. The window function `count(*) OVER()`is applied, which counts all the qualifying rows.
3. The `ORDER BY`rules are applied and the qualifying rows are sorted
4. The `LIMIT`and `OFFSET`rules are applied and the appropriate sub-set of sorted qualifying rows is returned.

##### Updating the code

With the brief explanation out of the way, let's get this up and running, begin by updating `internal/data/filters.go`file to define a new `Metadata`struct to hold the pagination metadata, along with a helper to calculate the vlaues.

Finally, need to update our `listMoviesHandler`handler to receive the `Metadata`struct returned by `GetAll()`and include the information in the JSON response for the client.

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

	// Set the supported sort values
	input.SortSafeList = []string{
        "id", "title", "year", "runtime", "-id", "-title", "-year", "-runtime"}

	// Validate the filters
	data.ValidateFilters(v, input.Filters)

	// check the validator instance for any errors and use the failvalidationResponse() helper
	if !v.Valid() {
		app.failedValidationResponse(w, r, v.Errors)
		return
	}

	// Call the GetAll method to retrieve movies
	movies, metadata, err := app.models.Movies.GetAll(input.Title, input.Genres, input.Filters)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	err = app.writeJSON(w, http.StatusOK, envelope{"movies": movies, "metadata": metadata}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}
```

Feel tree to restart the API and try out this new functionality by making some different requests to the `GET /v1/movies`endpoint. And it try making a request with a filter applied, U should see that the `last_page`value and `tatal_records`count changes to reflect the applied filters.

```sh
curl "localhost:4000/v1/movies?genres=adventure"
curl "localhost:4000/v1/movies?page=100"
```

### Rate Limiting

If U're building an API for public use, then it's quite likely that you will want to implement some form of *rate limiting* to prevent clients from making *too many* requests too quickly, and putting excessive strain on your server.

Essentially, we want this middleware to check how many requests have been received in the last `N`seconds and if there have been to many -- then it should send the client a 429 *too many requests* response. Position this middleware before our main app handlers.

- About the principles behind token-bucket rate-lmiter algorithms and how we can apply them in the context of an API or web application.
- How to create middleware to rate-limit requests to your API endpoints -- first by making a single rate global limiter, then exending it to support per-client limiting based on IP address
- How to make limiter behaviro configurable at runtime, including disabling the rate limiter altogether for testing.

#### Global rate Limiting

Build things up slowly and start by creating a single *global rate limiter* for our app. This will consider all the requests that our APi receives -- instead of writing own rate-limiting logic from scratch, which would be quite complex and time-consuming, can leverge the `x/time/rate`package to help us here. This privides a tried-and-tested imp of a token bucket rate limiter.

Before we start writing any code, let's take a moment to explain how token-bucket rate limiters work -- The description from the official `x/time/rate`documentation says -- 

- Will have a bucket that starts with `b`tokens in it.
- Each time receive a HTTP request, we will remove one token from the bucket
- Every 1/r seconds, a token is added back to the bucket -- up to maximum of `b`total tokens.
- If receive an HTP request and the bucket is empty, then should return a 429 *Too many Requests* response.

In order to create a token bucket rate limiter from `x/time/rate`-- will need to use the `NewLimiter()`function.

```go
// Note that the limit type is an alias for float64
func NewLimiter(r Limit, b int) *Limiter

// Allow 2 requests per second, with a maximum 4 requests in a burst
limiter := rate.new(2, 4)
```

#### Enforcing a global rate limit

Ok, with that high-level explanation out of the way, let's jump into some code and see how this works in practice. One of the nice things about the middleware pattern that we are using it that it is straightforward to include *initialize* code which only runs when we *wrap* sth with the middleware, rather than running on every request that the middleware handles -- 

```go
func (app *application) exampleMiddleware(next http.Handler) http.Handler {
    // Any code here will run only once, when we wrap the with the middleware
    return HttpHandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        next.ServeHTTP(w, r)
    })
}
```

In the case, will make a new `rateLimit`middleware method which creates a new rate limiter as part of the initialization code, and then uses this limiter for every request that it subsequently handles.

```go
func (app *application) rateLimit(next http.Handler) http.Handler {
    // Initilize a new rate limiter which allows an average of 2 requests per second
    // With a maximum of 4 requests is a single burst
    limiter := rate.NewLimiter(2, 4)
    
    // the func we are returning is a closure, with closes over the limiter variable
    // then we call the rateLimitExceedRequest() helper to return a 429 too many
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        if !limiter.Allow() {
            app.rateLimitExceededRepsonse(w, r)
            return
        }
        next.ServeHTTP(w, r)
    })
}
```

In this code, whenever we call the `Allow()`method on the rate limiter exactly one token will be consumed from the bucket. If there are no tokens left in the bucket, and `Allow()`will return `false`and that act as the trigger for us send client a 429 Too many requests response.

```go
func (app *application) rateLimitExceededResponse(w http.ResponseWriter, r *http.Request) {
	message := "rate limit exceeded"
	app.errorResponse(w, r, http.StatusTooManyRequests, message)
}
```

Then, lastly in the `routes.go`file want to add the `rateLimit()`middleware to our middleware chain -- this should come after our *panic* recovery middleware -- 

```go
func (app *application) routes() http.Handler {
    router := httprouter.New()
    //...
    return app.recoverPanic(app.rateLimit(router))
}
```

Restart the API, then in another terminal window execution the following command to issue a batch 6 requests to our `GET /v1/healthchck`endpoint in quick succession.

```sh
for i in {1..6}; do curl http://localhost:4000/v1/healthcheck; done
```

#### IP-based Rate Limiting

Using a glboal rate limiter can be useful when U want to enforce a strict limit on the total rate of requests to your API -- Don't care where the requests are coming from. But it's generally more common to want an individual rate limiter for each client - so that one bad client making too many requests doesn't affect all the others.

A conceptually straightforward way to implement this to create an in-memory *map* of *rate limiters* -- using the IP address for each client as the map key.

Each time a new client makes a request to our API, will initialize a new rate limiter and add it to the map. For any subsequent requests, will retreive the client's rate limiter from the map and check whether the request is permitted by calling its `Allow()`method, just like we did before.

But there is one thing to be aware of -- *by default* -- maps are not safe for concurrent use. This is a problem for us cuz our `rateLimit()`middleware may be running in multiple goroutines at the same time.

```go
func (app *application) rateLimit(next http.Handler) http.Handler {
	// define a client struct to hold the rate limiter and last seen time for each client
	type client struct {
		limiter  *rate.Limiter
		lastSeen time.Time
	}

	// Declare a mutex and a map to hold the client's IP addresses and rate limiters
	var (
		mu      sync.Mutex
		clients = make(map[string]*client)
	)

	// Launch a background which remove old entries from the client from once every minute
	go func() {
		for {
			time.Sleep(time.Minute)
			mu.Lock()
			// loop through all clients, if they haven't seen within the last three minutes
			for ip, client := range clients {
				if time.Since(client.lastSeen) > 3*time.Minute {
					delete(clients, ip)
				}
			}
			// Importantly, unlock mutex when the cleanup is complete
			mu.Unlock()
		}
	}()

	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		ip, _, err := net.SplitHostPort(r.RemoteAddr) // extract the client's IP
		if err != nil {
			app.serverErrorResponse(w, r, err)
			return
		}

		mu.Lock()
		if _, found := clients[ip]; !found {
			// Create and add a new struct to the map if it doesn't already exist
			clients[ip] = &client{
				limiter: rate.NewLimiter(rate.Limit(app.config.limiter.rps), app.config.limiter.burst),
			}
		}

		// update the last seen time for the client
		clients[ip].lastSeen = time.Now()

		if !clients[ip].limiter.Allow() {
			mu.Unlock()
			app.rateLimitExceededResponse(w, r)
			return
		}
		mu.Unlock()
		next.ServeHTTP(w, r)
	})
}
```

#### Deleting old Limiters

The code above will work, but there is a slightly problem -- the `clients`map will grow indefinitely -- taking up more and more resources with every IP address and rate limiter that we add.

## Support Vector Machines

A SVM is powerful and versatile machine learning model, capable of performing linear or non-linear classification, regression, and even novelty detection. SVMs shine with small to medium-sized nonlinear datasets - especially for classification tasks -- However, they don't sclae very well to very large datasets -- 

Distance measurement is a foundational component in many ML algorithms, especially thos that rely on similarities or differences between data points. Understanding how to measure the distance between points in feature space is crucial for tasks such as clustering, classification, and regression.

#### SVM classification

The core idea of support vector machines (SVMs) is most easily understood in a visual way. The left figure shows the decision boudaries of 3 possible linear classifiers. The left plot shows the decision boudnaries of 3 possible linear classifiers. The model whose decision boundary is represented by the dashed line is so bad that it does not even separate the classs properly. The other two models work perfectly on this training set, but their decision boundaries come so close to the instances that these models will probably not perform as well on new instances.

In contrast, the solid line in the plot on the right represents the decision boundary of an SVM classifier; this line not only separates the two classes but also stays as far away from the closest training instances as possible. You can think of an SVM classifier as fitting the widest possible street (represented by the parallel dashed lines) between the classes. This is called *large margin classification*.

```py
import matplotlib.pyplot as plt
import numpy as np
from sklearn.svm import SVC
from sklearn import datasets

# 加载鸢尾花(Iris)数据集
iris = datasets.load_iris(as_frame=True)

# 为了方便二维可视化，只提取两个特征：花瓣长度 (petal length) 和 花瓣宽度 (petal width)
X = iris.data[["petal length (cm)", "petal width (cm)"]].values
y = iris.target

# SVM主要用于二分类（多分类是基于二分类实现的）。
# 这里我们只保留类别0 (Setosa) 和 类别1 (Versicolor) 的数据
setosa_or_versicolor = (y == 0) | (y == 1)
X = X[setosa_or_versicolor]
y = y[setosa_or_versicolor]

# SVM Classifier model
# 创建并训练一个线性核的 SVM 分类器
# C=1e100（一个极大的数）表示使用“硬间隔”（Hard Margin）分类。
# 也就是说，模型会严格要求所有数据点必须在虚线边界之外，不允许任何误分类或压线。
svm_clf = SVC(kernel="linear", C=1e100)
svm_clf.fit(X, y)

# Bad models
x0 = np.linspace(0, 5.5, 200)

# 随便捏造了三条直线方程，代表三个差劲的分类器
pred_1 = 5 * x0 - 20
pred_2 = x0 - 1.8
pred_3 = 0.1 * x0 + 0.5

def plot_svc_decision_boundary(svm_clf, xmin, xmax):
    # 获取SVM训练后得到的权重 w 和偏置 b
    w = svm_clf.coef_[0]
    b = svm_clf.intercept_[0]

    # 决策边界的方程是: w0*x0 + w1*x1 + b = 0
    # 我们要在二维平面画图，横坐标是x0，纵坐标是x1。所以将其转换为 x1 = ... 的形式：
    # At the decision boundary, w0*x0 + w1*x1 + b = 0
    # => x1 = -w0/w1 * x0 - b/w1
    x0 = np.linspace(xmin, xmax, 200)
    decision_boundary = -w[0] / w[1] * x0 - b / w[1]

    # 计算上下间隔（Margin）的边界（虚线）
    margin = 1/w[1]
    gutter_up = decision_boundary + margin
    gutter_down = decision_boundary - margin
    
    # 获取支持向量（Support Vectors），即刚好落在虚线边缘上的那些数据点
    svs = svm_clf.support_vectors_

    # 画出实线（决策边界）和两条虚线（间隔边界）
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

- This creates and trains the SVM model.
- **`kernel="linear"`**: Tells the SVM to use a straight line (or flat plane) to separate the classes.
- **`C=1e100`**: `C` is the regularization parameter. Setting it to an astronomically high number (1×101001×10100) forces the model to perform **Hard Margin Classification**. This means the model strictly forbids any data points from crossing the margin boundaries (no misclassifications or points inside the "street"  are allowed).

##### Defining the Decision Boundary Function 

```py
def plot_svc_decision_boundary(svm_clf, xmin, xmax):
    w = svm_clf.coef_[0]
    b = svm_clf.intercept_[0]
```

- After training, the SVM finds the optimal weights (`w`) and bias (`b`).
- The general equation for a 2D linear decision boundary is: `w0x0+w1x1+b=0w0x0+w1x1+b=0.`
- To plot this on a 2D graph, we must solve the equation for x1x1 (the y-axis). This gives us the formula to draw the solid black line (the decision boundary).

#### Practical Experience Sharing

When running an SVM with Python, such as `scikit-learn` in `SVC` , it's important to keep the following in mind:

1. Data must be standardized/normalized! SVM is extremely sensitive to the scale of data. If the range of feature A is , 0−10000−1000 and the range of feature B is 0−10−1 , SVM is completely misled by feature A. must be processed using such as `StandardScaler` .
2. If you don't know which kernel function to choose, choose RBF.
3. How to adjust ginseng? GridSearchCV cross-validation is often used to find the best combination γγ of CC and (usually on a logarithmic scale, such as 0.1,1,10,1000.1,1,10,100 .
4. Multi-classification problem: The underlying SVM is a binary classifier. For  multi-classification, common strategies are OvR (One-vs-Rest,  one-to-many) or OvO (One-vs-One, one-to-one). `scikit-learn` The OvO policy is used by default.

##### Soft Margin Classification

If we strictly require that all samples be off the street and on the right side, this is called hard margin classification. There are two main problems with hard interval classification:

1.  It is only suitable for cases where the data is completely linearly separable.
2. It is very sensitive to outliers.

To avoid these problems, need a more flexible model. The goal is to find a balance between street width and margin violations. This is called soft margin classification.

### using `useRouter`

The next.js `useRouter`hook allows programmatic navigation. Unlike `Link`, can't be used in an RSC, so the consuming component must be a Client Component.

- `push`-- Performs Client-side navigation, adding a new entry to the browser history
- `replace`-- Performs client-side navigation, without adding a new entry to browser history
- `refresh`-- Refreshes the current route without losing any state.

```tsx
function SomeComponent() {
    const router = useRouter();
    function handleClick() {
        if(someClick()) 
            router.push('/some-path');
        else
            router.push('/some-other-path');
    }
    return <button onClick={handleClick}>Action</button>
}
```

#### Creating `Shared`layout

In this section, we will create a header for our app containing links to the `Home`and `Posts`pages, we will use the shared layout capabilities of Next.js to implement this.

##### Understanding layout components

In next.js, a shared layout is defined in a special file called `layout.tsx`Shared layouts can be defined on any route -- 

```tsx
export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html
      lang="en"
      className={`${geistSans.variable} ${geistMono.variable} h-full antialiased`}
    >
      <body className="min-h-full flex flex-col">{children}</body>
    </html>
  );
}
```

The file's content is a React component set the default export -- The component's name can be a meaningful name of our choice -- this component is sensibly named `RootLayout`cuz it will be rendered for every route. Layout component can be RSCs or Client Components. In our app, `RootLayout`in an RSC. The page component for the rendered route will create shared header.

##### Creaing a header

Will create a `Header`component in our app containing links to the `Home`and `Posts`pages -- will then add `Header`to `RootLayout`to be visible in all routes.

```tsx
export function Header() {
    return(
        <header>
            <Link href="/">Home</Link>
            <Link href="/posts">Posts</Link>
        </header>
    );
}
```

We are going to improve the styling of the header links a little. We will style the active link so that it stands out -- will use a hook called `usePathname`from next.js to get the active path to check against the link's path to determine whether it active -- to start with, make the following highlighted changes.

```tsx
'use client';
import Link from "next/link";
import {usePathname} from "next/navigation";

export function Header() {
    const pathname = usePathname();
    return (
        <header>
            <Link href="/"
                  className={pathname === "/" ? 'active' : ''}>Home</Link>
            <Link href="/posts"
                  className={pathname === '/posts' ? 'active' : ''}>Posts</Link>
        </header>
    );
}
```

That complets our shared header and this section on shared layout - to recap, a shared layout component is defined in `layout.tsx`-- the root layout is shared across all paths and is in the `app`folder.

#### Creating dynamic routes -- 

When will learn about dynamic routes in the section and use it to fully implement the blog post route. In Next.js, a dynamic route allows U to create pages that can respond to different URL parameters.

Carry out the following steps to make the blog post route dynamic. We will also display the blog post title and description in its page component.

```tsx
export default async function Post({params}: {params: Promise<{id:string}>;}) {
    const id = (await params).id;
    return <main>Blog post {id}</main>
}
```

Let's add some validation to ensure the `id`router parameter is numeric -- inform the user that the page isn't found.

```tsx
import {notFound} from "next/navigation";

export default async function Post({params}: {params: Promise<{id:string}>;}) {
    const id = Number((await params).id);
    if(!Number.isInteger(id)) {
        notFound();
    }
    return <main>Blog post {id}</main>
}
```

Add some validation to ensure the `id`parameter is numeric -- if isn't numeric, inform the user the page isn't found.

```tsx
import {posts} from "@/data/posts";

export default async function Post({params}: {params: Promise<{id:string}>;}) {
    const id = Number((await params).id);
    if(!Number.isInteger(id)) {
        notFound();
    }

    const post = posts.find(
        (post)=>post.id===Number(id),
    );
    
    return (
        <main>
            <h2>{post.title}</h2>
            <p>{post.description}</p>
        </main>
    )
}
```

That completes this section on dynamic routes -- here is quick recap -- 

- Dynamic routes in next.js allow U to create pages that respond to URL parameters -- used this feature to display different blog posts based on the `id`parameter.
- The `params`prop or the `useParams`hook in Client Components can access the route parameters and dynamicaly update the content based on the URL.

##### Using `Search`Parameters

Search parameters are part of a URL that comes after the `?`chacter and separated by the `&`character. Search parameters are sometimes preferred to the query parameters -- in the following URL, type and when are search parameters -- https://somewhere.com/?type=sometype&when=recent.

In next.js, search parameters can be accessed via a `searchParams`props as follows -- 

```tsx
export default async function Page({
	searchParams,
}: {
	searchParams: Promise<{
		[key: string]: string | string[] | undefined;
	}>;
}) {
    const params = await searchParams;
        return (
        <main>
        	Searching: {params.type}, {params.when}
        </main>
    );
}
```

The type annotation for `searchParams`is a little complex, let's break it down -- 

- `[key:string]`-- is in index sigature representing any property name.
- The union that follows the index signature is all the types that search parameters can have.
- The `type`is wrapped in the `Promise`type cuz `searchParams`is asynchronous.

```tsx
'use client';

export function SomeComponent() {
    const searchParams = useSearchParams();
    const type = searchParams.get('type');
    const when = searchParams.get('when');
}
```

##### Adding search functionality to the app

We will add a search input to the header of the app. Submitting a search will take the user to the `Posts`page with a filtered set of blog posts matching the search criteria.

```tsx
export function Header() {
    const pathname = usePathname();
    return (
        <header>
            <Link href="/"
                  className={pathname === "/" ? 'active' : ''}>Home</Link>
            <Link href="/posts"
                  className={pathname === '/posts' ? 'active' : ''}>Posts</Link>
            <Form action="/posts">
                <input type="search"
                       name="critieria"
                       placeholder="Search"
                       aria-label="Search blog posts" />
            </Form>
        </header>
    );
}

export default async function Posts({searchParams}: {
    searchParams: Promise<{ [key: string]: string | string[] | undefined; }>;
}) {
    const criteria = (await searchParams).criteria;
    const resolvedPosts =
        typeof criteria === 'string' ? posts.filter((post) =>
            post.title.toLowerCase().includes(criteria.toLowerCase()),
        ) : posts;
    const resolvedHeading = typeof criteria==='string'
        ? `Posts for ${criteria}`: 'Posts';
    return (
        <main>
            <h2>{resolvedHeading}</h2>
            <ul>
                {resolvedPosts.map((post) => (
                    <li key={post.id}>
                        <Link href={`/posts/${post.id}`}>
                            {post.title}
                        </Link>
                        <p>{post.description}</p>
                    </li>
                ))}
            </ul>
        </main>
    )
}
```

