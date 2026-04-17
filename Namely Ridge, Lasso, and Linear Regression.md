### Namely Ridge, Lasso, and Linear Regression

Then their performance is compared on a test set.

```py
# linear regression with L2 regularization
# Linear regressin with L1 regulaization
from sklearn.linear_model import Ridge, Lasso

# Mean square error and Coefficient of decision R^2
from sklearn.metrics import mean_squared_error, r2_score

# create and train model -- 
ridge_model = Ridge(alpha=1.0)
ridge_model.fit(X_train, y_train)
```

- `alpha`-- The regulaized strength parameter
- The larger the alpha -- the stronger the regularization, the smaller the coefficients with be compressed and the similar the model.

```py
lasso_model = Lasso(alpha=10.0, max_iter=10000, tol=0.001)
lasso_model.fit(X_train, y_train)
```

- `alpha`-- regularized strength, here used `alpha=10.0`is used, which is relatively large and easy to squeeze many coefficients into 0.
- `max_iter=10000`-- Maximum number of iterations
- `tol=0.001`Convergent tolerance

Make predictions -- 

```py
y_pred_ridge = ridge_model.predict(X_test)
y_pred_lasso = lasso_model.predict(X_test)
y_pred_linear = linear_model.predict(X_test)
```

Calculate the evaluation metrics and organzie them into DataFrames -- 

```py
metrics = {
    'Model': ['Ridge Regression', 'Lasso Regression', 'Linear Regression'],
    'Mean Squared Error': [...],
    'R-squared': [...]
}

metrics_df = pd.DataFrame(metrics)
metrics_df = metrics_df.sort_values('Mean Squared Error', ascending=True)  # 按 MSE 从小到大排序（最好模型在最上面）
```

| 模型                 | 正则化类型 | 效果                                         | 典型应用场景                   | alpha 含义            |
| -------------------- | ---------- | -------------------------------------------- | ------------------------------ | --------------------- |
| **LinearRegression** | 无         | 可能过拟合，系数可能很大                     | 数据干净、特征少、无多重共线性 | -                     |
| **Ridge**            | L2（岭）   | 收缩系数，但不会变为 0                       | 多重共线性严重（特征高度相关） | 越大 → 系数越接近 0   |
| **Lasso**            | L1（套索） | 可以把不重要的系数直接变为 **0**（特征选择） | 特征很多，想自动做特征选择     | 越大 → 越多系数变为 0 |

In the regression problem of ML, L1 regularization and L2 regularization are the core to solve model overfitting and deal with multicollinearity. They limit the size of the model coefficentis by adding a penality term to the loss function.

1. Core principles and mathematical defnintions - 

   The std loss function for linear regression is mean square eror (MSE). Regularization is based on this, plus a plenaty term `w`related to the weight vector.

2. Ridge regression adds the sum of squares of the absolute values of weights to the loss function.

3. Applicable scenarios -- when there is a high correlation between features

Lasso regression -- Adds the *sum* of the absolute values of the weights. Application scenairos -- feature sparseness, when suspect that only a few features have a significant impact on the results.

| **Characteristics**            | **Ridge (L2)**                                               | **Lasso (L1)**                                               |
| ------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| **Penalty items**              | The sum of squares of the coefficients (L 2  norm)           | The absolute value of the coefficient and (L 1  norm)        |
| **The coefficient is reduced** | tends to 0, but never equals 0                               | A sparse solution is generated and the partial coefficient becomes 0 |
| **Feature selection**          | It does not have the ability to select features              | Automatic feature selection function                         |
| **Compute performance**        | The analytical solution exists, and the computational efficiency is high | Non-convex optimization, usually using the coordinate descent method |
| **Impact on outliers**         | Relatively robust                                            | More sensitive                                               |

#### What is `ElasticNet`

It uses both L1 and L2 regular penalities, which can leverage the strengths of both and compensate for their shortcomines.

- Advantages of Lasso: Unimportant feature coefficients can be changed directly to 0 (automatic feature selection)
- Disadvantages of Lasso: When features are highly correlated (multicollinearity), Lasso will randomly select one of the features and ignore the others.
- Ridge's advantages: It handles multicollinearity well and contracts the coefficients of all relevant features evenly.
- Disadvantages of Ridge: It does not change the coefficient to 0, and it is not possible to select features.

##### Two core parameters of `ElaticNet`

1) `alpha`-- Control the overall regularization strength. `alpha=0`equivalent to ordinary linear regression. The larger the `alpha`-- the stronger the regularization, the smaller the model coefficient.
2) `l1_ratio`-- The most imporatant and unique parameter.
   - Control the mixing ratio of `L1`and `L2`
   - `l1_ratio=0`-- Pure Ridge regression
   - `l2_ratio=1`-- Pure Lasso regression
   - `l1_ratio=.5`-- half L1 and half L2.

```tex
损失函数 = MSE + alpha * (l1_ratio * |w|₁ + (1 - l1_ratio) * ||w||₂²)
```

##### `ElasticNet`Scenarios

- A large number of dataset features
- Strong multicollinearity between features
- Want to do feature selection at the same time
- Expect the model to be more stable than Lasso.

## Concurrency: Practice

Contexts are omnipresent when working with concurrency in Go, and in many situations, it may be remcommended to propagate them. However, context propagation can sometimes lead subtle bugs, preventing subfunctions from being correctly executed.

Consider the following example, expose an HTTP handler that performs some tasks and returns a resonse, But just before returning the response, also want to send it to a Kafka topic. Don't want penalize the HTTP consumer lagency-wise, so we want the publish action to be handled async within a new goroutine. Assume that we have at our disposal a `publish`function that accepts a context so the action of publishing a message can be interrupted if the context is canceled. Here is a possible implementation.

```go
func handler(w http.ResponseWriter, r *http.Request) {
    response, err := doSomeTask(r.Context(), r) // performs some tasks to compute the HTTP resp
    if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }
    
    go func() {
        err := publish(r.Context(), response)
        // Do sth with err
    }()
    writeResponse(response)
}
```

This context comes from a classic disucssion of Go language concurrency and conext best practices, and the core question is how to proplerly handle `conetxt`cancellation signals when starting an async goroutine in an HTTP handler.

- First, execute `doSomeTask()`to get a `response`.
- Return the resonse to the client.
- At the same time, Want to send this `response`async to Kafka -- don't want to increase the waiting time of the client.

```go
func handler(w http.ResponseWriter, r *http.Request) {
    response := doSomeTask(r.Context())   // 使用请求的 context

    // 异步发送到 Kafka
    go func() {
        if err := publish(r.Context(), response); err != nil {  // ← 这里传播了请求的 context
            log.Println(err)
        }
    }()

    // 立即返回 HTTP 响应
    writeResponse(w, response)
}

func handler(w http.ResponseWriter, r *http.Request) {
    response := doSomeTask(r.Contxt())
    go func() {
        if err := publish(r.Context(), response); err != nil {
            log.Println(err)
        }
    }()
}
```

Firt we call a `doSomeTask`function to get a `response`variable. It's used within the goroutine calling `publish`and to format the HTTP response.

##### What went wrong -- core Race Condition

Go's `net/http`package has special behavior for the requested `context(r.Context())`.

- The requested context is canceled when any of the following occurs `ctx.Err() == context.Canceled`.
- The client actively disconnects
- HTTP/2 requests are canceled
- The most important point is the context is automatically canceled when the handler function returns and the response has been written back to the client.

Intent - Let publish run in a background goroutine without blocking the client. Core race Condition -- Go's `net/http`package has a special behavior for the requested `conext(r.Context())`. The requested context is canceled when any of the following occurs -- `ctx.Err() == context.Canceled`

1. The Client actively disconnects.
2. HTTP/2 requests ae canceled
3. The most important ponit is that the context is automatically canceled when the handler function returns and the response has been written back on the client.

The most important point is that the context is automatially canceled when the handler function returns and the response has been written back to the client. This lead to a race condition -- 

- If `publish`finishes before writing the response -> everything works fine
- If the write resonse completes first and then `publish`is still doing `r.Context()`has been canceled, the `publish`function immediately returns `conext.Canceled`error, message publishing failed.

##### Essence of the problem

Wanted to publish to continue running independently of the HTTP request lifecycle, but U passed it a `Context`lifeclycle, but you passed it a Context that would cancel as the response was writtn, causing the async task to be unexpected interrupted.

With the client already receiving the response, still want to reliably sned the message to Kafka, and not fail cuz the conext is canceled.

Simple fx for bugs -- use `conext.Background()`-- 

```go
err := publish(context.Background(), response)
```

This writing solves the problem, but has a glaring flaw -- This writing solves the problem, but has a glaring flaw -- 

- If important values are carried the context of the original request, these values are lost.
- If U can't continue to use these request-level metadata in `Publish`to correlate logs or trace links.

##### Correct Solution -- Customize the Context for Disengagement Cancel

The author gives an elegent impementation -- keep only the value, but strip the cancellation signal and the deadline.

```go
type detach struct {
    ctx context.Context
}

func (d detach) Deadline() (time.Time, bool) {
    return time.Time{}, false  // 永不过期
}

func (d detach) Done() <-chan struct{} {
    return nil                     // 永远不会收到取消信号
}

func (d detach) Err() error {
    return nil                     // 永不返回错误
}

func (d detach) Value(key any) any {
    return d.ctx.Value(key)        // 保留所有父 context 的值
}
```

How to use -- 

```go
go func() {
    // 关键修复：使用 detach 包装
    detachedCtx := detach{ctx: r.Context()}
    if err := publish(detachedCtx, response); err != nil {
        log.Println("publish failed:", err)
    }
}()
```

##### Built-in Solution for Go 1.21+ 

Starting with Go 1.21, the std lib provides a more concise and official way.

```go
import "context"

// 使用 context.WithoutCancel
detachedCtx := context.WithoutCancel(r.Context())

err := publish(detachedCtx, response)
```

##### Summary and best Practices

This example illustrates a common pitfall of context in Go - 

- `context`is not just about canceling signals, it also carries values
- The `context`lifecycle of an HTTP request is strongly bound to the end of the handler.
- When U want to start an async, background, fire-and forget task, don't propagate the context of the request.
- The correct approach is -- strip the cancellation signal, but keep the value.

### Starting a goroutine without knowning when to stop it

Goroutines are easy and cheap to start -- so easy and chep that we may not necessarily have a plan for when to stop a new goroutine, which can lead to leaks. Not knowning when a stop a goroutine is a design issue and a common concurency mistake in Go.

##### What is `GoRoutine`leak -- 

The author first explains the cost of leakage from a quantitative perspective -- 

- Each goroutine starts with at a least 2 KB stack memroy
- The stack can grow dynamically
- In addition, goroutine holds variable references.
- After the leak -- this memory is never reclaimed by the GC, and the longer the program runs. The higher the memory footprint and may enentually OOM.

##### In terms of resources

- goroutine may hold -- 
  - Dbs connection
  - HTTP client connection
  - Open file handle
  - socket Netwok socket
  - mutex -- Locks timers, channels, etc
- These resources are not automatially shut down -- resulting in -- 
  - The dbs connection pool is exhausted
  - File descriptor exhaustion
  - Waste of external system resources.

##### Typical leak scenarios -- goroutine with unclear stop point -- 

A parent goroutine calls a function that returns a *channel* and then creates a new goroutine that receives messages from this channel at the time. In terms of memory, an goroutine starts with a minimimum stack size of 2KB, whcih can grow and shrink as needed.

### Deep Checking Dependencies

The deepndencies we've added to the array have been strings. Js primitives like strings, booleans, numbers, etc., are comparable - A string would equal a string as expected. However, when we start to compare objects, arrays, and functions, the comparison is different, fore, if compared two arrays -- 

```go
if([1,2,3]!=[1,2,3]) {
    console.log("but they are the same");
}

const array = [1,2,3];
if (array==array) {
    console.log("because it's the exact same instaance");
}

const useAnyKeyToRender = () => {
  const [, forceRender] = useState();

  useEffect(() => {
    window.addEventListener("keydown", forceRender);
    return () => window.removeEventListener("keydown", forceRender);
  }, []);
};

function App() {
    useAnyKeyToRender();
    useEffect(() => {
        console.log('RENDER');
    }, [words]);
    return <h1>Component</h1>
}
```

Declaring `words`outside the scope of the `App`would solve the problem - 

```tsx
const words = ['sick', 'powder', 'day'];
function App() {
    useAnyKeyTorRender();
    useEffect(()=> {
        console.log("fresh render");
    }, [words]);
    return <h1>Components</h1>
}
```

The dependency array in this case refers to one instance of `words`that's declared outside of the function. The *fresh render* effect does not get called again after the first render cuz the `words`is the same instance as the last render.

```jsx
const useAnyKeyToRender = ()=> {
    const[, forceRender]= useState();
    useEffect(() => {
        window.addEventListener('keydown', forceRender);
    }, []);
}
```

```jsx
const useAnyKeyToRender = ()=> {
    const [, forceRender] = useState();

    useEffect(() => {
        window.addEventListener('keydown', forceRender);
        return ()=> window.removeEventListener('keydown', forceRender);
    }, []);
}

function App() {
    useAnyKeyToRender();
    useEffect(() => {
        console.log('RENDER');
    }, []);
    return <h1>Open the console</h1>
}
```

