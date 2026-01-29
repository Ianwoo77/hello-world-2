# Feature Scaling and Transformation

One of the most important transformations you need to apply to your data is *feature Scaling* -- Why, and proper use of feature scaling, espeically min-max scaling, and how to use it correctly in Scikit-Learn. Namely, Machine learning alg don’t perform well when the input numerical attributes have very different scales -- 

#### Detailed Explanation -- 

- Scale difference problem -- in real data, the value range of diffenrent features can vary greatly.
- Consequence -- without scaling, ML models (espicially disance-based algs) such as KNN, SVM, or gradient-based alg such as linear aggression, NN, will consider features will large numbers to be more important.
  - The model trends to focus on numbers of rooms and ignores revenue, even though *revenue* is actually critical to predicating house prices
  - This can cause model training to slow down convergence or train a bised model.
- To mainstream approaches -- there are two ways to have all attributes at the same scale -- 
  - Min-max scaling -- 
  - Standardization -- converting data into a distribution witha mean of 0 and variance of 1.

The most important part of this text -- and is also the most error-prone for novices -- Namely-- 

Rules -- Fit the scalers to the training data only, once u have a trained scaler, you can then use it to `transform()`any other set.

1. Fit -- Calculate the statics of the data, such as minimum and maximum -- this step can only be done for the Training set.
2. Transformation -- Modify the data value using the calculated Min and Max, this step is for the training set, validation set, test set, and feature new data.

##### Whey can’t fit test sets -- 

If U just use data form a test set to calculate min/max -- -- called data leakage.

outlier about new data -- 

- Training set range 100 becomes 1, if new data is 120, it will become 1.2, then beyond the range 0~1
- Solution -- Scikit-Learn `MinMaxScaler`has a parameter `clip=True`-- if set to True, it will force the outlier value to be truncated at 0 or 1, preventing outliers from breaking the range.

##### Detailed Explanation of Min-max scaling (Normlizaiton) -- 

It is often referred to as normalization. It compresses data linearly into a fixed range, typically between 0 and 1. Namely -- if x equal to the minimum the result is 0, and equal to the maximum the result is 1.

Scikit-Learn tool -- `MainMaxScalar`-- 

```python
from sklearn.preprocessing import MinMaxScaler

scaler = MinMaxScaler()
# 1. int training set cal min and max
scaler.fit(X_train) 

# 2. transform training set
X_train_scaled = scaler.transform(X_train) 

# 3. 用同样的 scaler 转换测试集 (千万不要重新 fit X_test!)
X_test_scaled = scaler.transform(X_test) 
```

- parameter -- `feature_range`-- 
- The default is (0, 1)
- App scenarios -- mentions that NN generally prefer zero-mean inputs, in this case, you can set `feature_range=(-1, 1)`, the data to be distributed between -1 and 1 so tha the mean is closer to 0.

The `feature_range`-- hyperparameter -- lets U change the range. Fore:

```python
from sklearn.preprocessing import MinMaxScaler

min_max_scaler = MinMaxScaler(feature_range=(-1, 1))
housing_num_min_max_scaled = min_max_scaler.fit_transform(housing_num)
```

#### Standardization

 is different, first it subtracts the mean value, then it divides the result by the std deviation. It differs significantly fromt he previously mentioned Min-Max scaling -- especially when dealing with outliers.

1. Mathematical definition -- transforms data in two steps -- 
   - Subtract the mean -- move the center pointer of the data to 0
   - Divide by standard divation -- adjust the degree of discreteness of the data.
2. Outcome characteristics -- 
   - The mean value of the processed data is 0
   - The std deviation of the processed data is 1
   - This distribution is offered as the z-score.

##### Core difference from normalization (min-max)

| **Characteristics**         | **Min-Max Scaling (Normalization)**                          | **Standardization (Z-Score Scaling)**                        |
| --------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| **Scope Limits**            | Strictly limited to a specific range (usually **0 to 1** or -1 to 1). | **No fixed range.** Values typically fall between -3 and 3, but can theoretically be uncapped. |
| **Sensitivity to Outliers** | **Very sensitive.** A single extreme outlier can "squish" all other data points into a tiny range. | **Robust.** It is less affected by outliers as it centers data around the mean. |
| **Mathematical Goal**       | Rescales the data to fit within a bounded interval.          | Shifts the distribution to have a **mean of 0** and a **standard deviation of 1**. |
| **Applicable Scenarios**    | Image processing, Neural Networks, and algorithms that require fixed ranges. | Logistic Regression, SVM, and PCA (algorithms that depend on variance or distance). |

#### Why is standardization more resistent to outliers -- 

- Fore, revenue range for normal data 0 to 15
- An incorrect outler, for 100
- If U use Min-max (normaizlied) to 0-1 -- The maximum value becomes 100 and the minimum value is 0
- The maximum value of 15 for normal data is mapped to 15/100 = 0.15.
- So All normal data is compressed into a very small range of 0 to .15. If the model’s view, the difference between these data becomes minimal, causing the model to be usable to learn the laws of normal data, known as data crushing.

So, use Standardization -- 

- The mean and standard divation will be stretched a little large by 100, but not as extreme as Min-max.
- Normal data will still be distributed aournd 0, and an outlier of 100 can be large number.
- Consequences -- the relative distance between normal data is preserved, and the model can still distinguish between normal data, while outler only exists as a far away number and do not break the overall structure.

```python
from sklearn.preprocessing import StandardScaler

std_scaler = StandardScaler()
# fit_transform 一步到位：
# 1. fit: 计算 housing_num 的均值和标准差
# 2. transform: 应用公式 (x - mean) / std 进行转换
housing_num_std_scaled = std_scaler.fit_transform(housing_num)
```

As mentioned earlier, although we use `fit_transform`-- in the actual project, you will still have to follow the iron rule of only fit on the training set, transform on the test set.

- Normalization does not force data into a fixed range, but allows data to conform to the characteristics of a std normal distribution -- mean 0, variance 1.
- If you data may contain outliers-- or if use an alg that assumes that the data conforms to a Gassian distribution, normalization is often a better choice.

```python
from sklearn.preprocessing import StandardScaler

std_scaler = StandardScaler()
housing_num_std_scaled = std_scaler.fit_transform(housing_num)
```

#### What is a heavy tail

- Def -- if the tail of distribution declines more slowly, and there is still a consideraable amount of data distriuted in the extreme area, it is called a long tail.
  - normal Distribution -- values that are far from the mean very rare
  - Long-tail distribution -- large values far from the mean are not uncommon.
- The problmes caused by long-tailed distribution -- squashing -- Consequence -- Machine learning models will feel that there is little difference between 1 and 10 -- 

Solution -- transform first, then scale - Goal - make the distribution more symmetrical -- prefearable close to normal distribution -- this makes the model easier to learn.

- Square Root/Power
- Principle -- the square root compress large values more than small values
- Logarithm - App scenarios -- extremly severe long tails, usually in line with power law distribution. `log(x)`.
- Principle -- Logarithms can turn multiplicative relationships into additive rel -- greatly compressing numerical spans.

Summary and best practice process -- 

1. Observe the distribution of data -- Draw a histogram -- 
2. Spot the long tail -- if the graphic is a tall lump on the left and lone tail on the right
3. transform -- Use the `np.log()`or transform `np.sqrt()`the feature to make it look more like a bell
4. Scale -- On the transformed data, use the standardscaler or MinmaxScaler.

Namely -- Instead of scaling the long-tail data directly, use log to sqrt to reshape it before scaling.

```python
fig, axs = plt.subplots(1, 2, figsize=(8, 3), sharey=True)
housing["population"].hist(ax=axs[0], bins=50)
housing["population"].apply(np.log).hist(ax=axs[1], bins=50)
axs[0].set_xlabel("Population")
axs[1].set_xlabel("Log of population")
axs[0].set_ylabel("Number of districts")
save_fig("long_tail_plot")
plt.show()
```

Another approach to handle heavy-tailed features consists in *bucketizing* the feature and RBF similarity Feature.

1. Another way to deal with long-tail distribution -- bucketing -- 

   The value range of numerical features is divided into several buckets or boxes then, replace the original value with the index (ID) of the bucket where the data resides.

2. Specific operations (based on quantiles) -- 

   - It is recommended to use a percentile to divide to ensure that the amount of data in each bucket in approprixmate the same.
   - Suppose divide your income into 10 buckets, the lowest 10% of income is at barrel 0, and highest 10% and barrel 9.
   - Result -- the original long-tail distribution became a uniform distribution.

3. Zoom -- Once binning is complete, the data becomes an integer from 0 to 9. Can directly divide the total number of buckets and map it to sth between 0-1 without the need for complex scaling.

##### Multimodal distributions

The histogram of the data has two or more significant peaks -- 

- Bucketizing + OneHotEncoder -- For multimodal distirbutions. the rel between the size of the value and the target variable may not be a simple linear REL.
- Steps -- 
  1. Binning -- divide the age into segments -- 
  2. Categorization -- This step is critical - this step is critical -- instead of treating the bucket ID as number 0, 1, 2 -- think of it as a category.
  3. Encoding -- then use OneHotEncoder to convert these categories into binary vectors.

## Fixing the implementation

How should we have implemented `FirstRune`correctly, then -- well, that’s not really important for the discussion of fuzz testing -- there are a variety of ways we could write `FirstRune`correctly, including the rather dull one of simply calling `utf8.DecodeRuneInString`as the tests does -- just lik:

```go
func FuzzFirstRune(f *testing.F) {
	f.Add("Hello")
	f.Add("World")
	f.Fuzz(func(t *testing.T, s string) {
		got := runes.FirstRune(s)
		want, _ := utf8.DecodeRuneInString(s)
		if want == utf8.RuneError {
			t.Skip()
		}
		if want != got {
			t.Errorf("given %q (0x%[1]x): want '%c' (0x%[2]x)",
				s, want)
			t.Errorf("got '%c' (0x%[1]x)", got)
		}
	})
}

func FirstRune(s string) rune {
	for _, r := range s {
		return r
	}
	return utf8.RuneError
}
```

```sh
go test -fuzz . -fuzztime=10s
```

## Wandering Mutants

But what does it mean to cover a piece of code -- and how useful is that metric hen evaluating the actual quality of our tests -- in this chapter, will explore the mechanics and meaning of *test coverage* -- 

| **Term**             | **Definition**                                               | **The "Seth Godin" Perspective**                             |
| -------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| **Test Coverage**    | A metric showing the percentage of source code executed during testing. | It is **easy to measure**, but a high percentage doesn't always mean your code is "safe." |
| **Mutation Testing** | The practice of intentionally injecting small bugs (mutants) into code to see if tests fail. | It is **harder to measure**, but more important because it tests the *strength* of your assertions. |

##### Core philosophy -- test behavior -- not lines of Code -- 

- Myth -- many developers think that the goal of testing is to executing as much as each line of Go code possible
- Exact answer -- the real purpose of testing is to verify what the code does
- Revelation -- Even if your test runs through a line of code, it doesn’t mean that the code logic is correct. Testing should focus on the system’s user behavior and business logic, rather then just running through lines of code.south

To win-win Stragegy -- When it is found that some code not covered -- The authors propose a very sharp set of binary decisions that improve code quality regardless of the results -- 

- This line of code is important to use behavior -- 
  - U have to add tests to it
  - The result -- the system is more robust
- This line of code is not important to user behavior -- 
  - Countermeasure -- This means that this dead code or redundant logic and should be removed directly
  - The result -- the codebase is much cleaner.

##### Beware of the 100% coverage trap

- Reality -- it’s normal that it’s almost impossible to achieve 100% coverage for real projects
- What is Gaming the system -- to force 100% coverage, write some pointless test cases.

#### What is test coverage 

Test coverage is a term that describes how much of a package’s code is exercised by runing the package’s tests -- if executing the test suite causes 80% of the package’s source statement to be run, say that the test coverage is 80%.

```sh
go test -cover
go test -coverprofile=coverage.out
go tool cover -html=coverage.out
```

This is a very profound engineering perspective, many websites think that the more tests, the better, but the author remind us -- 

- Maintenance costs -- Test code is also code -- they need to be written, read, run and maintained.
- Long-term burden -- if write a worthless test -- will consume computing resources every time it runs for years to come, and it will need someone to maintain it every time you refactor code.
- Return on investment -- Every line of test code is an investment - can’t recoup its wages by find potential bugs.

##### The essence of Testing -- Trade-off

Testing is not a dogma, but a Pagmatic effort.