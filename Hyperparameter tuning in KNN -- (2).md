# Hyperparameter tuning in KNN -- (2)

Hyperparameter tuning is essentially the *fine-tuning* phase of machine learning. While the model learns pattern from the data -- U provide the settings that givern how that learning happens. For KNN, tuning is especially vital cuz the model's logic is entirely dependent on its proximity to other data points.

#### Core Hyperparameters in KNN -- 

When tuning a KNN model, you are generally looking at three primary levers -- 

1. `k`-- (`n_neighbors`)-- The number of neighbors to consider. A small `k`can lead to overfitting, while large `k`can lead to underfitting.
2. `Weights`-- 
   - `Uniform`-- All neighbors have an equal vote.
   - `Distance`-- Closer neighbors have a higher influence on the result than those furhter away.
3. `Metric`-- The formula used to calculate distance -- `Euclidean`and `Manhattan`.

##### The Search process -- Grid search & Cross-Validation

The code you provided uses `GridSearchCV`-- which is the industry standard for exhausitive tuning - here is how the *Grid* and `CV`work together.

1. `Grid`-- Think of the `param_grid`as a menu. If U have 5 points for `k`-- for weights, and 2 for metrics, and 2 for metrics, Grid search will build 20 different versions of model to see which one performs best.
2. *Cross-Validation* -- The `cv=5`parameter means the data is split into 5 folds, for every one of those 20 model versions -- `cv=5`fore--
   - The model is trained on 4 folds and tested on the 5th.
   - This repeats 5 times so every piece of data acts as a test set once
   - The scores are averaged.

| **Step**   | **Component**   | **Purpose**                                                  |
| ---------- | --------------- | ------------------------------------------------------------ |
| **Step 3** | `param_grid`    | Defines the search space (the specific values you want to test). |
| **Step 4** | `GridSearchCV`  | The engine that runs the combinations and manages Cross-Validation. |
| **Step 5** | `.fit()`        | The heavy lifting. This is where the model cycles through all combinations. |
| **Step 6** | `.best_params_` | Returns the "winning" configuration.                         |

```py
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

##### How it works

Hyperparameter optimization is a necessary step in nearly ML pipeline, including those that contain KNN -- 

- Grid Search -- This technique exhausitvely searches through a special parameter grid to find the best combination of hyperparameter based on model performance
- Cross-valiation -- By using cross-validation during grid search, you ensure that your model is evaluted on different subsets of data, which helps prevent overfitting and provides a more reliable esitmate of model.

##### Evaluating model performance

Once U have identified best hyperparmeters using grid search, can do the following -- 

- Test set evaluation -- Use the best parameters to fit a final model on the training set and evaluate its performance on a separate set.
- Performance metrics -- Depending on your task - use appropriate metrics such as accuracy score for classiiers on MSE for regressors to access how well tuned model performs.

The main function this code is to generte and draw a learning curve for the machine learning model -- the learning curve is very important diagnostic tool that helps U determine whether the model is currently overfitting, 

```py
import numpy as np
from sklearn.model_selection import learning_curve

train_sizes, train_scores, test_scores = learning_curve(
    grid_search.best_estimator_, # 1. 使用的模型
    X_train,                     # 2. 训练集特征
    y_train,                     # 3. 训练集标签
    cv=5,                        # 4. 交叉验证折数
    train_sizes=np.linspace(0.1, 1.0, 10), # 5. 训练集大小的划分
)
```

- `learning_curve`-- It continuously changes the size of the training set and then iteratively tains and tests the model.
- `grid_search.best_estimator_`-- Means that U have prevously used Grid search to find the model with optimal hyperparameters, and now use this optimal model to draw the graph.
- `cv=5`-- Use 5-fold cross-validation, this means that for each data volume, the model is trained and tested 5 times to ensure the stability of the results.
- `train_sizes=np.linspace(0.1, 1.0, 10)`-- `np.linspac`generates a series of 10 numbers from 0.1 to 1.0.

##### Return value -- 

- `train_size`-- The number of samples actually used per training 1D array.
- `train_scores`-- The model's score on the training set. It is a 2D matrix that represents the score of 5 cross-valiations across 10 different data valumes
- `test_scores`-- the model's score on the validation set.

```py
import matplotlib.pyplot as plt

plt.figure(figsize=(10, 6)) # 设置画布大小为宽10、高6

# 绘制训练集得分曲线
plt.plot(train_sizes, np.mean(train_scores, axis=1), label="Training score")

# 绘制交叉验证集（测试集）得分曲线
plt.plot(train_sizes, np.mean(test_scores, axis=1), label="Cross-validation score")

plt.xlabel("Training examples") # X轴标签：训练样本数量
plt.ylabel("Score")             # Y轴标签：模型得分（如准确率、R2等）
plt.legend(loc="best")          # 显示图例，自动放在最佳位置
plt.title("Learning curve")     # 图表标题
plt.show()                      # 显示图表
```

When the code runs, a graph is generated with two lines inside - can diagnose your model based on the movement of these two lines - 

1. High Variance / Overfitting -- 
   - Phenomenon -- The taining score has always been high -- while the Corss-validation score is relatively low, and there is a large gap between the two lines
   - Conclusion -- The model memorizes the training data, but the generalization ability is poor.
   - Solution -- on the graph, if the two lines tend to get closer as the sample size increases, it is helpful to collect more training data.
2. High Deviation / underfitting -- 
   - Phenomeonon - the training score and Cross-validation score are relatively low, and the two lines are close together, finally become parallel straight lines.
   - Conclusion -- The model is too simple to even understand the laws of the training data.
3. Goo Fit -- The two lines are close together and both eventually stabilize at a high score level.

```py
from sklearn.metrics import confusion_matrix
import matplotlib.pyplot as plt
import seaborn as sns

y_pred = grid_search.best_estimator_.predict(X_test)
class_names = iris.target_names

cm = confusion_matrix(y_test, y_pred)
plt.figure(figsize=(8, 6))
sns.heatmap(
    cm, annot=True, fmt='d', cmap='Blues',
    xticklabels=class_names,
    yticklabels=class_names
)
plt.xlabel('Predicted')
plt.ylabel('True')
plt.title('Confusion Matrix')
plt.show()
```

It looks like U've hit a classic `NameError`-- This happens cuz even though U might have the logic right, Python doesn't recognize the function `classification_report`cuz it hasn't been imported into your current session yet.

```py
from sklearn.metrics import classification_report
import pandas as pd

report_dict = classification_report(
    y_test, y_pred, target_names=class_names, output_dict=True
)
report_df = pd.DataFrame(report_dict).transpose()
styled_df = report_df.style.background_gradient(
    cmap="Blues", subset=["precision", "recall", "f1-score"]
).format(
    {
        "precision": "{:.3f}",
        "recall": "{:.3f}",
        "f1-score": "{:.3f}",
        "support": "{:.0f}",
    }
)
print("\nClassification Report:")
display(styled_df)
```

- `Precision`-- Of all points predicted as a certain class, how many were actually that class.
- `Recall`-- Of all actual members of a class, how many did the model correctly find.
- `F1-Score`-- The harmonic mean of the two -- useful when U want a single balance between Precision and Recall.

##### Understanding evaluation metrics

There are a variety of methods to evaluate the performance of classification models, and scikit-learn provides several options for utilizing the most common ones.

1. Learning curves - These are visual representaions that plot the model's performance against the size of the training dataset, showing how well the model learns as it is exposed to more training examples, allowing anaysts to identify potential issues such as underfitting.
2. Confusion Matrix -- A confustion matrix delivers a visual summary of predictions made by a classification model. It shows the counts of TPs, TNs, FPs, and FNs -- this matrix helps visualize how well the model is performing acors different classes.
3. Classification report -- The classification report is a scikit-learn function that comines several metrics into a single, easy-to-read table, including the followings -- 
   - Precision -- Precision measures the accuracy of positive predictions. `(TP+FP)/TP`
   - Recall -- Recall measures the ability of a model to identify all relevant intances. `(TP+FN)/TP`.
   - `F1-score`-- The `F1-score`is the harmonic mean of precision and reall, providing a single metric that balance both cercerns -- it is particularly useful when dealing with imbalanced datasets. `F1 = 2 x precision + recall/precision x recall.
   - Accuracy -- Accuracy measures the ratio of total correct preditions out of all predictions made.

## Using embedded file systems

Before we continue, take a quick moment to dicuss embedded file systems in more details -- cuz there are couple of things that can be confusing when U first encounter them.

- Can only use the `//go:embed`directive on global variables at package level, not within functions or methods -- if U try to use it in a function or method -- you will get the error `go:embed cannot apply to var inside func`.
- Fore, when U use the direcive `//go:embed "<path>"`to create an embedded file system, the path should be *relative* to the source *code file* containing the directive.
- The embedded file system is rooted in the directory which contains the `//go:embed`directive.
- Paths cannot contain `.`or `..`elements - nor may they begin or end with `/`. This essentially retricts U to only embedding files that are contained the same directory as the source code which ahs the `//go:embed`directive.
- If the path is for directory, then all files in the directory are recursively embedded, except files with names that begins with `.`and `_`, if U want to include these files U should use the `*`wildcard character in the path.

```go
// Read the SMTP settings from command-line flags into the config struct.
// Mailtrap settings as the default
flag.StringVar(&cfg.smtp.host, "smtp-host", "sandbox.smtp.mailtrap.io", "SMTP host")
flag.IntVar(&cfg.smtp.port, "smtp-port", 25, "SMTP port")
flag.StringVar(&cfg.smtp.username, "smtp-username", "b9a90a67a5bd09", "SMTP username")
flag.StringVar(&cfg.smtp.password, "smtp-password", "e1e98fb1189811", "SMTP password")
flag.StringVar(&cfg.smtp.sender, "smtp-sender",
    "Greenlight <no-reply@greenlight.alexedwards.net>", "SMTP sender")
```

And then the final thing we need to do is update our `registerUserHandler`to actually send the email -- 

```go
// users.go
func (app *application) registerUserHandler(w http.ResponseWriter, r *http.Request) {
    err = app.mailer.Send(user.Email, "user_welcome.html", user)
    if err != nil {
        app.serverErrorResponse(w, r, err)
        return
    }
    
    err = app.writeJSON(w, http.StatusCreated, envelope{"user": user}, nil)
    if err != nil {
        app.serverErrorResponse(w, r, err)
    }
}
```

```sh
BODY='{"name": "Bob Jones", "email": "bob@example.com", "password": "pa55word"}'
curl -w '\nTime: %{time_total}\n' -d "$BODY" localhost:4000/v1/users
```

### Retrying email end attempts

If want can make the email sending process a bit more robust by adding some basic *retry* functionality to the `Mailer.Send()`method.

```go
func (m Mailer) Send(recipient, templateFile string, data any) error {
    // try sending the email up to three times aborting and returning final
    // error, we sleep for millisconds between each attempt.
    for i:=1; i<=3; i++ {
        err = m.dailer.DialAndSend(msg)
        if err == err {
            return nil
        }
        time.Sleep(500 * Milliscond)
    }
    return err
}
```

This retry functionality is a relatively simple addition to our code, but it helps to increase the probability that emails are successuflly sent in the event of transient network issues.

#### Sending Background Emails

As we mentioned briefly in the last chapter, sending the welcome email from the `registerUserHandler`method adds quite a lot of latency to the toal request/response round-trip for the client.

One way could reduce this latency is by sending the email in a *background goroutine*. This would effectively decouple the task of sending an email from the rest of the code in our `registerUseHandler`.

```go
func (app *application) registerUserHandler(w http.ResponseWriter, r *http.Request) {
    // Launch a goroutine which runs an async function that sends the welcome email.
    go func() {
        err = app.mailer.Send(user.Email, "user_welcome.html", user)
        if err != nil {
            app.logger.Error(err.Error())
        }
    }()
    
    // Note that we also change this to send the client 202 Accepted status code
    err = app.writeJSON(w, http.StatusAccepted, envelope{"user": user}, nil)
    if err != nil {
        app.serverErrorReponse(w, r, err)
    }
}
```

When this code is executed now, a new background goroutine will be launched for sending the welcome email. The code in this background goroutine will be executed *concurrently* with the subsequent code in our `registerUserHandler`, which means we are no longer waiting for the email to be sent before we return a JSON response to the client.

- Use the `app.logger.Error()`method to manage any errors in our backgournd goroutine. This is cuz by the time we encounter the errors, the client will probably have already been sent a *202 Accepted* response by our `writeJSON()`helper.
- The code running in the background forms a *clousre* over the `user`and `app`variables - it's important to be aware that these *closed over* variables are not scoped to the backgound goroutine.

```sh
BODY='{"name": "Carol Smith", "email": "carol@example.com", "password": "pa55word"}'
curl -w '\nTime: %{time_total}\n' -d "$BODY" localhost:4000/v1/users
```

#### Recovering panics

It's important to bear in mind that any panic which happens in this background goroutine will not be automatically receovered by our `recoverPanic()`middleware or Go's `http.Server`, and will cause our whole application to terminate -- in very background goroutines -- this is less of a worry. But the code involved in sending an email is quite complex and risk of a runtime panic is non-negligible.

```go
func(app *application) registerUserHandler(w http.ResponseWriter, r *http.Request) {
    //...
    // launch a background goroutine to send the welcome email.
    go func() {
        defer func() {
            if err != recover(); err != nil {
                app.logger.Error(fmt.Sprintf("%v", err))
            }
        }()
        
        // Send the welcome email
        err = app.mailer.Send(user.Email, "user_welcome.html", user)
        if err != nil {
            app.logger.Error(err.Error())
        }
    }()
    
    err = app.writeJSON(w, http.StatusAccpeted, envelope{"user", user}, nil)
    if err != nil {
        app.serverErrorResponse(w, r, err)
    }
}
```

## Understanding React `Suspense`

React Suspense enable components to wait for async tasks during rendering. A common async task that `Suspense`is used for is *data fetching*. It allows the rendering of some JSX elements to be *suspended* while data is being fetched, allowed other elements to be rendered normally.

The `Suspense`fallback can be shown to the user before suspended elements cuz RSCs containing suspended elements are streamed to the brwoser. So the Suspense fallback will be sent to the browser in the first chunk, with suspended elements following when they are ready.

```tsx
export default function Page() {
    return(
    	<Suspense fallback={<div>Loading...</div>}>
        	<Name />
        </Suspense>
    );
}

async function Name() {
    const name = await getName();
    return <div>Hello, {name}</div>
}
```

#### Implementing loading indicators 

We will use React Suspense to add loading indicators to parts of the page components for the blog post list and details. Extract the async parts of the components into child components so that they can be wrapped.

```tsx
export function Loading() {
    return(
        <div className="skeleton">
            <div className="skeleton-item-title"></div>
            <div className="skeleton-item-desc"></div>
        </div>
    )
}
```

Will extract the data fetching and rendering of the blog post list from `Posts`into a `PostList`component.

```tsx
export async function PostList({criteria,}:
                               { criteria: string | string[] | undefined; }) {
    const resolvedPosts = typeof criteria === 'string'
        ? await getFilteredPosts(criteria)
        : await getAllPosts();

    return(
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
    )
}
```

Replace `ul`and `li`elements in the JSX with `PostList`inside a `Suspense`component -- like:

```tsx
return (
    <main>
        <h2>{resolvedHeading}</h2>
        <Suspense fallback={<Loading />}>
            <PostList criteria={criteria} />
        </Suspense>
    </main>
);
```

Start by adding a new file at `src/components/PostDetail.tsx`with the following content -- 

```tsx
export async function PostDetails({id,}: {id:number;}) {
    const post = await getPost(id);
    if(!post)
        return <p>Post not found</p>;
    return(
        <>
            <h2>{post.title}</h2>
            <p>{post.description}</p>
        </>
    );
}
```

#### Handling errors with React error boundaries

In this section, will learn about error handling using React error boundaries. With this knowledge, will improve that error handling in our app -- A React error boundary is component that catches errors in its children during rendering -- React error boundaries are available in React class components.

```tsx
export function SomeComponent() {
    return (
    	<main>
        	<h2>Some heading</h2>
            <ErrorBoudnary FallbackComponent={ErrorAlert}
                onError={(error, info)=> {
                    //...
                }}>
            	<SomeChildComponent />
            </ErrorBoudnary>
        </main>
    );
}
```

The `FallbackComponent`attribute allows an error component to replace the children that failed to render. The `onError`attribute allows to be captured, allowing them to be logged.

```tsx
'use client';

export function ErrorAlert({
                               error, resetErrorBoundary
                           }: { error: Error, resetErrorBoundary: () => void }) {
    return (
        <div role="alert">
            <h3>Sth went wrong</h3>
            <p>{error.message}</p>
            <button onClick={resetErrorBoundary}>Retry</button>
        </div>
    )
}
```

The error fallback component must be a Client Component. It takes in the following props -- 

- `error`-- This is raised `Error`object that contains all the information about the error.
- `resetErrorBoundary`-- this allows the state in the error boundary to be reset to reattempting rendering.

#### Implementing error boundaries

Will use `ErrorBoundary`from the `react-error-boundary`package. We'll be use this in the blog post list and detail pages -- carry out these steps -- 

```tsx
export function ErrorBoundary({children,}: {children: ReactNode;}) {
    return (
        <ReactErrorBoundary FallbackComponent={ErrorAlert}
                            onError={(error, info) => {
                                console.log("ErrorBoundary caught an error", error, info);
                            }}>
            {children}
        </ReactErrorBoundary>
    )
}
```

