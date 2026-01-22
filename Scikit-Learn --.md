# Scikit-Learn -- 

Scikit-learn provides a few functions to split datasets into multiple subsets in various ways the simplest function is `train_test_split()`, which does pretty much the same thing as the `shuffle_and_split_data()`function we defined earlier.

However, both these solution will break the next time you fetch an updated dataset -- To have a stble train/test split even after updating the dataset, a common solution is to use each instance’s identifier device whether or not it should go in the test set.

```python
from zlib import crc32

def is_id_in_test_set(identifier, test_ratio):
    return crc32(np.int64(identifier)) < test_ratio * 2**32

def split_data_with_id_hash(data, test_ratio, id_column):
    ids = data[id_column]
    in_test_set = ids.apply(lambda id_: is_id_in_test_set(id_, test_ratio))
    return data.loc[~in_test_set], data.loc[in_test_set]
```

The housing dataset does not have an identifer column, the simplest solution is to use the row index as the ID just like:

```python
housing_with_id = housing.reset_index()  # adds an `index` column
train_set, test_set = split_data_with_id_hash(housing_with_id, 0.2, "index")

housing_with_id["id"] = housing["longitude"] * 1000 + housing["latitude"]
train_set, test_set = split_data_with_id_hash(housing_with_id, 0.2, "id")
```

And the Scikit-Learn provides a few functions to split datasets into multiple subsets in various ways. The simplest function is `tain_test_slpit()`, which does pretty much the same thing as the `shuffle_and_split_data()`function we defined earlier -- with a couple of additional features. First, there is a `random_state`parameter that allows U to set the random generator seed.

```python
from sklearn.model_selection import train_test_split
train_set, test_set = train_test_split(housing, test_size=0.2, random_state=42)
```

This code represents ond of the most fundamental stps in a machine learning workflow -- *Dataset Splitting* -- its core purpose is to divide your data into a Training set and Test set - this ensures that after the model is trained, Can evaluate it on data has never seen before to test its real-world performance -- 

1. The Import -- `from sklearn.mode_selection import train_test_split`-- 
   - `Scikit-Lean`-- the most popular machine learning library for Python
   - `train_test_split`-- A built-in utility function designed to shuffled and split datasets into subsets automatically.
2. Parameter Breakdown
   - Housing -- your original dataset. It contains all your rows and columns
   - test-size=0.2 - Define the split ratio. 0.2 means 20%., 80% of the data goes to the training set. And 20% goes to the *test set* to act as a final exam.
3. `random_state = 42` -- This is a random seed.
   - For this generates *pseudo-random* anumbers - would get a different split every time you ran the code.
   - Benefit -- setting this to a fixed number.
4. Assignmnet -- `train_set, test_set = ..`the function returns two separate datasets.
   - `train_set`-- the data the model studies -- looks for patterns between features
   - `test_set`-- the held-out data, the model never sees this during training, it is used only at the very end to provide an unbiased evaluation of the model accuracy.

| **Component**              | **Purpose**                                                  |
| -------------------------- | ------------------------------------------------------------ |
| **Training Set**           | Used to fit the model parameters.                            |
| **Test Set**               | Used to estimate how the model will perform on new, unseen data. |
| **Overfitting Prevention** | Prevents the model from just "memorizing" the data instead of learning general rules. |

While random sampling is acceptable for large datasets - it risks introducing *Sampling bias* in smaller ones, and to ensure a sample accurately reprents the overall population, analysts use stratified sampling - where the population is divded into homogeneous subgroups and sampled proportionally -- When applying this to continuous data -- such as *median income* fro housing price predications-- the data must first be converted into categories -- it is crucial to create strate that are sufficient large to be statistically signicicant, but limited in number to avoid over-fragmentation.

To find the probability that a random sample of 1,000 people contains less than 48.5% female or more than 53.5% female when the population's female ratio is 51.1%, we use the [binomial distribution](https://en.wikipedia.org/wiki/Binomial_distribution). The `cdf()` method of the binomial distribution gives us the probability that the number of females will be equal or less than the given value.

```python
from scipy.stats import binom

sample_size = 1000 # total sample size
ratio_female = 0.511 # true proportion of females in the US population

# `cdf()` -- The cumulative distribution function, calculates the probablity that the random variable
# is less then or equal k
proba_too_small = binom(sample_size, ratio_female).cdf(485 - 1)
proba_too_large = 1 - binom(sample_size, ratio_female).cdf(535) # for `too many`
print(proba_too_small + proba_too_large)
```

This code is designed to verify the mathematical probability mentioned in the previous text regarding how purely random sampling can lead to sampling bias. Specifically, the text states, if you used urely random sampling, there is 10.7% chance of sampling a skewed test set.

```python
# rot=0 -- 
housing["income_cat"].value_counts().sort_index().plot.bar(rot=0, grid=True)
plt.xlabel("Income category")
plt.ylabel("Number of districts")
save_fig("housing_income_cat_bar_plot")  # extra code
plt.show()
```

1. The shape of Distribution - Will likely see a distribution that is somewhat *bell-shaped*
2. Sample Sufficiency -- need to ensure that even the smallest categories have a tall enough bar.

To be precise, the `split()`yields the training and test indices.

## Coverage is a signal, not a target

Argues that while metrics are useful, making them a specific goal leads to negative outcomes, It highlight the danger on test coverage as a definitive proxy for code quality.

- Goodheart’s Law - when a measure becomes a target, it creases t obe a good measure. When organizations set strict targets, individuals will game the system to maximujm that number rather than actually improving quality.
- The illusion of Quality -- Mangers often mandate coverage quotas cuz they want to boil complex code quality to a signal number. High test coverages does not guarantee high-quality software. And it is easy to srite useless code simply to satisfy the metric.
- The Cobra Effect - How perverse incentives create uninteded consquences.

### Using bebugging to discover feeble tests

The limits of Coverage and the value of *bebugging* - The passage highlights that test coverge metrics are insufficient cuz they measures only the breadth of test, not the depth. To address this, the author proposes two main starategies -

- Deep code Reading -- When evaluating a codebase, developers should manually review tests with the critical question -- whare are we really testing htere -- ensures tests aren’t just running code but are actively validating logic.
- Bug Seeding - to detect feeble tests -- tests are cover code but fail to verify properly -- the text suggests deliberately inserting bugs into the system -- if the existing test suite fails to catch these intentional errors, it proves that the tests are inadequate, regardless of thei coverage percentage.

#### Detecting unnecessary or unreachable code

Bebugging is good at identifying feeble tests, but that’s not the only reason it’s useufl. It’s quite possible that could insert some deliberate bug and find that no test fails, and that is okay. Fore, can deduce that the affected code simply isn’t necessary -- it apparently makes no difference to the program’s behaviour whether it works or not -- Fore:

```go
if false {
    return 1
}
```

While can see by inspection that the code like is unreachable, the same kind of bug can lurk in a much less obvious way. This isn’t telling us that our tests are feeble, just telling us that this code isn’t needed, which is true. While we can see by inspection that code like this is unreachable, the same kind of bug can lurk.