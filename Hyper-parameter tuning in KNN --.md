# Hyper-parameter tuning in KNN -- 

Hyperparameter tunning is a critical step in optimizing the performance of ML models, including KNN, what exactly is a hyerparmeter anyway -- when think about trining and ML model, can think of that model as a mathematical equation where we provide some input data and ouput data and train to determine the best set of parameters in the equation to generally match our inputs to our outputs.

The text contains some grabled characters due to OCR recognition errors -- `y = mx + b`, but I'll sort it for U in the details below.

##### Core concepts -- what are *parameters* and *Hyperparameters* 

- Parameters -- These are the variables that the *model learns during training*.

  Example of garbled characters in corrective text -- say we are doing a linear regression model -- in this formula, `x`it is the input data, and `y`it is the output data. And the slope `m`and intercept `b`are the parameters.

- Hyperparameters -- There are variables that are manually set by humans before training begins - 

  1. Hyperparameters do not participate in the direct calculation of the formula, but tell the model how it should learn -- in the KNN algorithm, the `K`value (find a few neighbors) is a hyperparameter, cuz the model itself does not calculate how best `K`is, and it must be specified by us.

- Preparation -- What hyperparameters d owe want to tune KNN -- In the code, the authors used the classic Iris dataset and decided to tune the 3 core hyperparameters of KNN.

  1. `n_neighbors`-- looking for the nearest neighbors -- 
  2. `weights`-- All neighbors have the same voting weight
  3. `distance`-- weighted by distance, the closer the neibhbor, the greater the voting power.

##### Core method -- Grid Search and Cross-validation

- `Grid Search`-- This is a brute force search method, it will combine all the hyperparameters we provide
  - Totoal number of combination, 5K x 2w x 2m = 20 different KNN model configuations
  - Grid Search will try all 20 of these situations and finally tell U which one works best
- `Cross-validation`-- CV - To prevent the model just happening to performing well on a single slice, the code introduces cross-validation here `cv=5`it stands for 50% off corss-validation -- it divides the training data into 5 parts, taking turns with 4 training and 1 valiation.

```py
from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split

iris = load_iris()
X = iris.data
y = iris.target

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=2024
)

from sklearn.model_selection import GridSearchCV
from sklearn.neighbors import KNeighborsClassifier

knn = KNeighborsClassifier()

# Define a hyperparameter grid
param_grid = {
    'n_neighbors': [3, 5, 7, 9, 11],
    'weights': ['uniform', 'distance'],
    'metric': ['euclidean', 'manhattan']
}

# Create a grid search
grid_search = GridSearchCV(
    knn, param_grid, cv=5, scoring='accuracy'
)

# Fit the grid search
grid_search.fit(X_train, y_train)

print("Best Parameters:", grid_search.best_params_)
print("Best cross-validation score:", grid_search.best_score_)
```

When execute the preceding code, scikit-learn's grid search approach determine which et of hyperparameters achieves the best performance, utilitzing cross-validation, and prints them out.

##### How it works -- 

Hyperparameter optimization is a necessary step in nearly every ML pipeline, including those that contain KNN -- 

- Grid search -- This technique exhaustively searches through a spcified parameter grid to find the best combination of hyperparameters based on model performance.
- Cross-validation -- By using cross-validation during grid search -- *k-fold* -- again, *k* is a stand-in for a number, you ensure that your model is evaluted on different subsets of data, which helps prevent overfitting and provides a more reliable estimate of model perforance.

##### Evaluating model performance

Once have identified the best byperparameters using grid search, U can do the following -- Lay it out cleanly and give U a practical example U can drop straight into your workflow.

- Test set evaluation -- Use the best parameters to fit a final model on the training set and evaluate its performance on a separate set.
- Performance metrics -- Depending on your task, use appropriate metrics such as accuracy score for classifiers or mean squared error (MSE) - for regressors to access how well your tuned model performs.

### Linear SVM Classification -- 

The core idea of SVM is eaiest to understand in a visual way -- shows a portion of the iris dataset presented at the end of Ch4 -- the two categories can obviously be easily separated by a straight line. The left figure shows the decision boundaries of 3 possible linear classifiers. The model where the dotted line represents is so bad that it doesn't even properly separate the two categories. The other two lines, while perfectly on the training set, have decision boundaries that are too close to the training simple.

In contrast, the solid line in the right graph represents the decision boundary of the SVM classifier -- this line not only manages to separate the two categories, but also moves as far awy as possible from the closest training samples. Can think of SVM as laying a *street a wide as possible* between two categories.

Its main purpose is to generate a comparison graph showing the three bad linear classification boundaries on the left the perfect boundaries of the SVM's Large Margin Classification on the right 

```py
import matplotlib.pyplot as plt
import numpy as np
from sklearn.svm import SVC
from sklearn import datasets

# 1. 加载鸢尾花数据集
iris = datasets.load_iris(as_frame=True)
# 2. 只提取两个特征：花瓣长度 (petal length) 和 花瓣宽度 (petal width)
X = iris.data[["petal length (cm)", "petal width (cm)"]].values
y = iris.target

# 3. 过滤数据，只保留类别 0 (Setosa) 和 1 (Versicolor)
setosa_or_versicolor = (y == 0) | (y == 1)
X = X[setosa_or_versicolor]
y = y[setosa_or_versicolor]
```

- Purpose -- In order to be able to draw on a 2D plane, we took only two features
- Binary classification -- the most basic application of SVM is binary classification. There are 3 types of irises, we filter them by condition, leaving only the first two -- the two are linearly and divisible in two-dimensional space.

##### Train SVM model

```py
# SVM 分类器模型
svm_clf = SVC(kernel="linear", C=1e100)
svm_clf.fit(X, y)
```

- SVC -- Support vector Classifier
- `kernel="linear"`-- Tell the model that we want to find a straight lines as the decision boundary, not a curve.
- `C=1e100`-- Extremely important parameter -- `C`is regularization parameter. In Scikit-learn, an oversized `C`value means that the model adopts a *Hard Margin* -- that is the model will never allow any training sample to be missorted. To achieve the perfect classification, it will find the most middle line as much as possible.

##### Defined several bad classification models -- 

```py
# Bad models
x0 = np.linspace(0, 5.5, 200) # 生成 X 轴的坐标点
pred_1 = 5 * x0 - 20          # 红色虚线对应的方程 (未完全分开)
pred_2 = x0 - 1.8             # 紫色实线对应的方程 (分开了，但紧贴数据)
pred_3 = 0.1 * x0 + 0.5       # 绿色实线对应的方程 (分开了，但紧贴数据)
```

Here 3 straight lines are artificially fabricated. Their purpose is to demonstrate -- while some straight lines can separate two types of flowers, they are too close to data points that it is easy to misjudge if new unknown data comes, this is the lack of *generalization ability*.

```py
def plot_svc_decision_boundary(svm_clf, xmin, xmax):
    # 1. 获取模型训练出的权重 (w) 和偏置 (b)
    w = svm_clf.coef_[0]      # 包含 [w0, w1]
    b = svm_clf.intercept_[0] # 截距 b

    # 2. 计算决策边界直线方程
    # 决策边界的数学表达式是: w0*x0 + w1*x1 + b = 0
    # 转换成画图用的 y = mx + c 的形式求 x1: => x1 = -w0/w1 * x0 - b/w1
    x0 = np.linspace(xmin, xmax, 200)
    decision_boundary = -w[0] / w[1] * x0 - b / w[1]

    # 3. 计算“间隔 (Margin)” 上下的两条虚线 (街道边界)
    margin = 1/w[1] 
    gutter_up = decision_boundary + margin   # 上边界
    gutter_down = decision_boundary - margin # 下边界
    
    # 4. 获取支持向量 (Support Vectors)
    svs = svm_clf.support_vectors_

    # 5. 绘制线条和点
    plt.plot(x0, decision_boundary, "k-", linewidth=2, zorder=-2) # 黑色实线：决策边界
    plt.plot(x0, gutter_up, "k--", linewidth=2, zorder=-2)        # 黑色虚线：上间隔
    plt.plot(x0, gutter_down, "k--", linewidth=2, zorder=-2)      # 黑色虚线：下间隔
    
    # 用浅灰色大圆圈标出支持向量
    plt.scatter(svs[:, 0], svs[:, 1], s=180, facecolors='#AAA', zorder=-1)
```

- The essence of SVM is to find a line that not only separates the data, but also has the widest street.
- `svm_clf.support_vectors_`-- Contains data points that happen to fall on the *edge of the street*. These points are called support vectors, and the entire model is actually supported and determined by these key points.

```py
# 创建一个 1行2列 的画布，共享 Y 轴
fig, axes = plt.subplots(ncols=2, figsize=(10, 2.7), sharey=True)

# ====== 左图：表现不佳的模型 ======
plt.sca(axes[0])
plt.plot(x0, pred_1, "g--", linewidth=2) # 绿虚线
plt.plot(x0, pred_2, "m-", linewidth=2)  # 紫实线
plt.plot(x0, pred_3, "r-", linewidth=2)  # 红实线
# 画出两类花的数据点
plt.plot(X[:, 0][y==1], X[:, 1][y==1], "bs", label="Iris versicolor") # 蓝色方块
plt.plot(X[:, 0][y==0], X[:, 1][y==0], "yo", label="Iris setosa")     # 黄色圆点
# 设置坐标轴标签和范围
plt.xlabel("Petal length")
plt.ylabel("Petal width")
plt.legend(loc="upper left")
plt.axis([0, 5.5, 0, 2])
plt.gca().set_aspect("equal") # 保持 X 轴和 Y 轴比例一致
plt.grid()

# ====== 右图：完美的 SVM 模型 ======
plt.sca(axes[1])
# 调用我们刚才写的核心函数画 SVM 的线
plot_svc_decision_boundary(svm_clf, 0, 5.5)
# 画数据点
plt.plot(X[:, 0][y==1], X[:, 1][y==1], "bs")
plt.plot(X[:, 0][y==0], X[:, 1][y==0], "yo")
plt.xlabel("Petal length")
plt.axis([0, 5.5, 0, 2])
plt.gca().set_aspect("equal")
plt.grid()

# save_fig("large_margin_classification_plot") # 这是作者自定义的保存图片函数，如果在你电脑上运行报错，注释掉这一行即可
plt.show() # 显示图表
```

##### To summarize the visual significance of this code -- 

1. Left -- while the purple and red lines perfectly separate the two types of flowers, they almost rub against flower dots -- if U use newly collected iris data to predict, it is easy to across the line and lead to prediction errors.
2. Right -- SVM is like building a straight highway as wide as possible between two piles of flowers. The decison-making boundary is in the middle of the highway. The few flowers circled by the large gray circle are the support vectors.

#### Soft Margin Classification -- 

If we strictly require that all samples be outside the margin and on the right side, then this is called *hard margin classification* -- But there are two main problems with hard interval classification.

1. It only works with linearly divisible data.
2. It is very sensitvie to outliers

Fore, shows the situation after adding only one outlier to the iris dataset -- in the left figure, a hard interval can no longer be found -- In the figure on the right, the decision boundary is significantly shifted compared when there are no outliers, and such a model is likely to not generalize well.

To avoid these problems -- we need a more flexible model, the goal is to find a balance between keeping the intervals as long as possible and margin violation -- The so-called spacing violation is when the sample falls in the middle of the street - or even on the wrong side. The method is called *soft margin classification*.

When U create an SVM model with Scikit-learn, can set several hyperparameters, including the regularized hyperparameter `C`-- 

- If U set `C`to smaller, get a model similar to the one on the left side of 
- If Set `C` larger size, get the model on the right.

As can see, decreasing `C`makes the interval larger, but it also leads to more internment violtions. The following Scikit-learn code loads the iris dataset and trains a linear SVM classifier to detct Iris virginica flowers.

The following Scikit-learn code loads the iris dataset and trains a linear SVM classifier to detect Iris virginica flowers. The pipeline first scales the features, then uses a `LinearSVC`with `C=1`.

```py
from sklearn.datasets import load_iris
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.svm import LinearSVC

iris = load_iris(as_frame=True)
X = iris.data[["petal length (cm)", "petal width (cm)"]].values
y = (iris.target == 2)  # Iris virginica

svm_clf = make_pipeline(StandardScaler(),
                        LinearSVC(C=1, random_state=42))
svm_clf.fit(X, y)

X_new = [[5.5, 1.7], [5.0, 1.5]]
svm_clf.predict(X_new)

svm_clf.decision_function(X_new) # array([ 0.66163411, -0.22036063])
```

- This value represents the signed distance from the sample point to the decision boundary
  - The positive -- model consider it to be of the positive class, and the higher the value, the higher the condifence.
  - The negative -- model considers it to be negative, and the higher the absolute value, the higher the confidence.
  - 0 - falls right on the decision boundary.
- So -- 
  - 0.66>0 -- The first strain strongly favors virgianica
  - -0.22<0 -- The second strain tends to be non-virginica.

## Using Model Setup and Registration

In the upcoming sections of this book, we are going to shift our focus towards users -- registering , activating them, authenticating them, and restricting access to our API endpoints depending on the permissions that they are.

- Create a new `users`table PostgresSQL for storing our user adata.
- Create `UserModel`which contains the code for interacting with our `users`table, valiating user data, and hashing user passwords
- Develop a `POST /v1/users`endpoint which can be used to register new users in our application.

#### Setting up the Users dbs table

Bebin by creating a new users table in our database, if you are following along -- use the `migrate`tool to generate a new pair of SQL migration files -- 

```sh
migrate create -seq -ext=.sql -dir=./migrations create_users_table
```

```sql
CREATE EXTENSION IF NOT EXISTS citext;

CREATE TABLE IF NOT EXISTS users (
    id bigserial PRIMARY KEY,
    created_at timestamp(0) with time zone NOT NULL DEFAULT NOW(),
    name text NOT NULL,
    email citext UNIQUE NOT NULL,
    password_hash bytea NOT NULL,
    activated bool NOT NULL,
    version integer NOT NULL DEFAULT 1
);
```

1. Loads the `citext`extension -- `citext`stands for case-insenstive text -- it provides a special data type -- also called `citext`- that behaves like `text`but ignores case when comparing values.
2. Only creates it if it isn't already installed -- if the `IF NOT EXISTS`clause prevents PostgreSQL from throwing an error if the extension is already present.

There are a few interesting about this `CREATE TABLE`statement that like to quickly explain -- 

1. The `email`column has the type `citext`-- this type stores text data exactly as it is inputted -- wihout changing the case in any way -- but *comparisons* against the data are always case-insenstive... including lookups on associated indexs.
2. We've got a `UNIQUE`contraint on the `email`column. Combined with the `citext`type - this means that no two wros in the dbs can have the same email value.
3. The `password_hash`column has the type `bytea`. In this column we will store a *one-way* hash of the *user*'s password generated using `bcrpt`not the plaintext pwd itself.
4. The `activated`column stores a boolean value to denote whether a user account is `active`or not. Will set this to `false`by default when creating a new user, and require the user to confirm their email address before set it to `true`.
5. We have also included `verson`number column, which we will increment each time a user record is updated - this will allow us to use optimistic locking to prevent race conditions when updating user records, in the same way that we did with movies earlier in the book.

Then execute the `up`migration -- 

```sh
migrate -path=./migrations -database=$GREENLIGHT_DB_DSN up
```

One important thing to point out here, the `UNIQUE`contrain on our `email`column has automatically been assigned the same `users_email_key`-- this will become relevant in the next chapter.

#### Setting up the Users Models

Now that our dbs table is set up -- we are going to update our `internal/data`package to contain a new `User`struct, and create a `UserModel`type -- create `internal/data/users.go`file to hold this new code -- like: Mentioned earlier, in this project will use bcrypt to hash user passwords before storing them in the dbs. So the first thing we need to do is install the `golang.org/x/crypto/bcrypt`package -- which provides an easy-to-use Go implementation of the bcrypt algorithm -- 

```sh
go get golang.org/x/crypto/bcrypt@latest
```

Then in the `internal/data/users.data.go`file, go head and create the `User`struct and helper methods like so.

## Implmenting query functions

```tsx
export async function getAllPosts() {
    const client = createClient({
        url: process.env.DB_URL ?? '',
    });
    const data = await client.execute(
        `SELECT id, title, description
         FROM posts`);
    client.close();
    return data.rows as unknown as Post[];
}
```

Used the `createClient()`to connect to the dbs. The dbs URL environment variable is accessed via the `process.env`object, which is the std way of accessing environment variable in `Next.js`-- The function return an object containing an `exectue`function, which allows the dbs to be queried.

We use the `execute`func to select the fields from the `posts`table, which is where our blog post data is. We then close the dbs connection return the rows in the query -- notice that a type assertion is used in the `return`statement to strongly type the returned data. This is a little messy cuz we need to assert to `unknown`before asserting `post[]`.

Implementing a similarly structured function to get filtered blog posts -- like:

```tsx
export async function getFilteredPosts(criteria:string) {
    const client = createClient({
        url: process.env.DB_URL ?? '',
    });
    const data = await client.execute({
        sql: `Select id, title, description
              FROM posts
              WHERE title LIKE ?`,
        args: ['%${criteria}%'],
    });
    
    client.close();
    return data.rows as unknown as Post[];
}
```

The main difference this time is that pass a SQL statement and a SQL parameter to the dbs client's `execute`function. The SQL statement contains a `WHERE`clause that filters the data using the `title`field and a parameter -- the SQL parameter value is passed via the `args`property in an array.

```tsx
export async function getPost(id: number) {
    const client = createClient({
        url: process.env.DB_URL ?? '',
    });
    const data = await client.execute({
        sql: `Select id, title, description
              FROM posts
              WHERE id = ?`,
        args: [id],
    });
    client.close();
    if (data.rows.length === 0) {
        return undefined;
    }
    return data.rows[0] as unknown as Post;
}
```

#### Calling query functions from RSCs -- 

We will now call the query functions we just implemented in the blog list and blog post detail RSCs -- follow -- 

```tsx
export default async function Posts({searchParams}: {
    searchParams: Promise<{ [key: string]: string | string[] | undefined; }>;
}) {
    const criteria = (await searchParams).criteria;
    const resolvedPosts =
        typeof criteria === "string"
            ? await getFilteredPosts(criteria)
            : await getAllPosts();
    const resolvedHeading =
        typeof criteria === "string"
            ? `Posts for ${criteria}`
            : `Posts`;
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
    );
}

// For [id]/page.tssx
export default async function Post({params}: {params: Promise<{id:string}>;}) {
    const id = Number((await params).id);
    if(!Number.isInteger(id)) {
        notFound();
    }

    const post = await getPost(id);

    return (
        <main>
            <h2>{post.title}</h2>
            <p>{post.description}</p>
        </main>
    )
}
```

#### Adding type safety to a database query

At the moment, we are trusting data from the dbs queries is of type `Post[]`for the `getAllPosts`and `getFilterPosts`functions, and also type `Post`for the `getPost`function. We know this is the case in our example, but in the real world, database schemas may change without connecting code being updated accordingly. This can happen when different teams own the dbs, and the code, and a dbs change isn't properly communicated.

If the type representing query data is incorrect, then code consuming wouldn't work as expected and may result in an unexpected runtime error. In our app, this would result in post list and detail pages not rendering correctly. To protect the code against unexpected dbs changes, the type of the data can be checked at runtime to see if it is as expected -- A popular library called `Zod`can elegantly do schmea validation checks.

```sh
npm i zod
```

Create a new file the `src/data`folder called `schema.ts`-- this will contain the `Zod`schemas for the dbs queries. To protect the code against unexpected dbs chanes, the type of the data can be checked at runtime to see if it is expected. A popular `Zod`can do schema validation checks.

```tsx
import {z} from "zod";

export const postSchema = z.object({
    id: z.number(),
    title: z.string(),
    description: z.string(),
});

export const postsSchema = z.array(postSchema);
```

We have defined two schemas -- 

- The first, `postSchema`, represents a single blog post. The schema specficiation an object with a numeric `id`property, and string `title`and `description`properties.
- The second, `postSchema`-- represents multiple blog posts. It builds on `postSchmea`simply specifying that it is an array of `postSchema`.

```tsx
export async function getAllPosts() {
 	//...
    return postsSchema.parse(data.rows);
}

export async function getFilteredPosts(criteria: string) {
    // ...
    return postsSchema.parse(data.rows);
}

export async function getPost(id: number) {
    // ...
    return postsSchema.parse(data.rows)[0];
}
```

The `parse`function in the `Zod`schemas performs the validation check. An error is thrown if the check fails. If the check is successful, the data passed into `parse`is returned and typed as per the schema.

```tsx
export async function getAllPosts() {
    const client = createClient({
        url: process.env.DB_URL ?? '',
    });
    const data = await client.execute(
        `SELECT CAST(id as text) as id, title, description
         FROM posts`);
    client.close();
    return postsSchema.parse(data.rows);
}
```

##### Adding loading indicators using React `Suspense`

Learn about React `Suspnse`and use it to implement a loading indicators in the RSCs that fetch data in our app. This will improve the loading user experience.

Currently, the data-fetching user experience in our app is reasonable cuz the process is quick. This is cuz everything is running locally, and so the latency is low. This is also cuz the dbs is small, and the queries are simple, so they execute fast, lastly, we are the only user using the app.

