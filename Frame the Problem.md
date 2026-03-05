# Frame the Problem

A sequence of data processing components is called a data *pipeline*. Pipelines are very common in machine learning systems. Components typically run asynchonously.

- DEF -- A data pipeline is a collection of data processing componetns that are commonly used in machine learning systems that need to process large amounts of data and transform.
- Operation mechanism -- Each component runs asynchronously and independently, and they do not communicate directly with each other.
- Pros -- 
  1. Easy to understand and divide labor
  2. Robust : If a component crashes, the downstream component can still continue to work with the last output data of the component for a period of time, without causing the entire system to be paralyzed immediately.
- cons -- Over-reliance on montioring -- Due to its high fault tolerance rate, if there is no comprehensive monitoring mechanism, component damage may to undetected for a long time.

| **Dimensions**                | **Task type**                        | **Judgment basis**                                           |
| ----------------------------- | ------------------------------------ | ------------------------------------------------------------ |
| **Learning style**            | **(Supervised Learning)**            | The training data is "labeled" (i.e., the known median house price for each region). |
| **Mission objectives**        | **Regression**                       | The goal of the model is to predict a **continuous number** (price), not a category. |
| **Regression to subdivision** | **(Univariate Multiple Regression)** | Use **multiple characteristics** (population, income, etc.) to predict **a single target value**. |
| **Data flow**                 | **(Batch Learning)**                 | The data volume is moderate and does not require rapid updates based on new incoming data in real time. |

#### Select a Performance Measure

```python
from pathlib import Path
import pandas as pd
import tarfile
import urllib.request
import os

def load_housing_data():
    tarball_path = Path("datasets/housing.tgz")
    extract_path = Path("datasets/housing")
    url = "https://github.com/ageron/data/raw/main/housing.tgz"

    # 1. if file not exist, download it
    try:
        if not tarball_path.is_file():
            Path("datasets").mkdir(parents=True, exist_ok=True)
            print("正在从 GitHub 下载加州房价数据...")
            urllib.request.urlretrieve(url, tarball_path)
            print("下载完成。")

        # 2. unzip
        with tarfile.open(tarball_path) as housing_tarball:
            housing_tarball.extractall(path="datasets")
            print("解压成功。")

    except (EOFError, tarfile.ReadError):
        # 3. 容错处理：如果文件损坏，删除它并报错，下次运行将重新下载
        print("检测到压缩包损坏，正在清理并重试...")
        if tarball_path.exists():
            os.remove(tarball_path)
        raise Exception("压缩包损坏。请再次运行此单元格以重新下载。")

    # 4. 读取 CSV
    return pd.read_csv(extract_path / "housing.csv")

# 运行函数
try:
    housing = load_housing_data()
    print(f"成功加载数据！数据集维度：{housing.shape}")
except Exception as e:
    print(e)
```

When `load_housing_data()`is called, it looks for the *dataset/housing*.  Fore, there are 20640 instances in the dataset, which means it is fairly small by ML learning std.

```python
housing.describe()
```

The `count, mean, min`and `max`rows are self-explanatory. `std`-- *standard deviation* is a measure of how dispersed data is. It tells us how far a set of data points is from their mean on average.

##### Standard deviation and percentile -- 

While std deviation measures overall volatility, it is usually analyzed in conjunction with the percentiles you mentioned. And the 25%, 50% and 75% -- Show the corresponding percentiles - percentiles represent the values below a given percentage of observations in a set of observations.

```python
import matplotlib.pyplot as plt

# extra code – the next 5 lines define the default font sizes
plt.rc('font', size=14)
plt.rc('axes', labelsize=14, titlesize=14)
plt.rc('legend', fontsize=14)
plt.rc('xtick', labelsize=10)
plt.rc('ytick', labelsize=10)
# bins -- how many buckets the data is divided into along the x-axis
housing.hist(bins=50, figsize=(12, 8)) # figsize controls the physical dimensions of the entire win
# save_fig("attribute_histogram_plots")  # extra code
plt.show()
```

##### What is a histogram -- 

Histograms are one of the most intutive ways to observe the distribution of numerical attributes. Its core components include -- 

- Horizontal Axis -- Represents the range of values for attributes
- Vertical Axis -- Indicates the number of instances that fall within the value range.

#### Creating a Test set

It may seem strange to voluntarily set aside part of the data at this stage. After all, you have only taken a quick glance at the data, and surely you should learn a whole lot more about it before U decide what algorithms to use.

```python
import numpy as np

def shuffle_and_split_data(data, test_ratio):
    shuffled_indices = np.random.permutation(len(data))
    test_set_size = int(len(data) * test_ratio)
    test_indices = shuffled_indices[:test_set_size]
    train_indices = shuffled_indices[test_set_size:]
    return data.iloc[train_indices], data.iloc[test_indices]
```

This code is a classic *from-scratch* imp of a train-test split. It’s a great way to understand what is happening under the hood before start using automated tools like Scikit-Learn’s func. If you pass in an integer `n`, returns a randomly scrambled integer array `n-1`from 0 to . And if you pass in an array, it returns a shuffled copy of the array without modifying the original array.

And why is it needed when partitioning a dataset -- When want to manually partition a dataset, the process is usually as follows -- 

1. Shuffle indexes -- Use `np.random.perumutation`to generate a set of random indexes.
2. Determine the split point -- fore, a total of 1000 pieces of data, and the test set accounts for 200.
3. Allocate data -- The data corresponding to the first 200 are assigned to the test set.

For this, if the raw data is sorted in some order, taking the top 20% of the data directly will result in the test set being *unrepresentative*.

```python
train_set, test_set = shuffle_and_split_data(housing, 0.2)
len(train_set)
```

Note that for this, it is not perfect, if run the program again, it will generate a different test set -- over time, will get to see the whole dataset, which is what you want to avoid.

```python
np.random.seed(42)
```

However, both these solutions will break the next time you fetch and updated dataset. To have a stable train/test split even after updating the dataset, a common solution is to use each instance’s -- If you simply use `np.random.permutation`-- the original training and test sets are *shuffled* and reorganized every time new data is added and the program is rerun.

```python
from zlib import crc32

# crc32() -- for the same input, the same 32-bit integer is always returned
def is_id_in_test_set(identifier, test_ratio):
    return crc32(np.int64(identifier)) < test_ratio * 2**32

def split_data_with_id_hash(data, test_ratio, id_column):
    ids = data[id_column]
    in_test_set = ids.apply(lambda id_: is_id_in_test_set(id_, test_ratio))
    return data.loc[~in_test_set], data.loc[in_test_set]
```

The housing dataset does not have an identifer column. The simplest solution is to use the row index as the ID.

```python
housing_with_id = housing.reset_index()  # adds an `index` column
train_set, test_set = split_data_with_id_hash(housing_with_id, 0.2, "index")

housing_with_id["id"] = housing["longitude"] * 1000 + housing["latitude"]
train_set, test_set = split_data_with_id_hash(housing_with_id, 0.2, "id")
```

And the Scikit-learn provides a few functions to split datasets into multiple subsets in various ways. Just like:

```python
from sklearn.model_selection import train_test_split
train_set, test_set = train_test_split(housing, test_size=0.2, random_state=42)
```

This just introduces a very critical concept in ML -- Stratified Sampling.

## Creating a validator package

To help us with validation throughout this project -- going to create a small `internal/validator`package with some simple reusable helper types and functions.

```go
type Validator struct {
	Errors map[string]string
}

func New() *Validator {
	return &Validator{Errors: make(map[string]string)}
}
```

Then need to add some generic functions like:

```go
func PermittedValue[T comparable](value T, permittedValues ...T) bool {
	return slices.Contains(permittedValues, value)
}

func Matches(value string, rx *regexp.Regexp) bool {
	return rx.MatchString(value)
}

func Unique[T comparable](values []T) bool {
	uniqueValues := make(map[T]bool)

	for _, value := range values {
		uniqueValues[value] = true
	}

	return len(values) == len(uniqueValues)
}
```

#### Making validation rules reusable

```go
func validateMovie(v *validator.Validator, movie *Movie) {
    v.Check(movie.Title != "", "title", "must be provided")
    v.Check(len(movie.Title)<=500, "title", "must be more than 500 bytes long")
    //...
}
```

Then in the `cmd/api/movies.go`file -- just like:

### Database Setup and configuration

```sh
go get github.com/lib/pq@v1
```

In the `cmd/api/main.go`file, just create a new `openDB()`helper -- use the `sql.Open()`to establish a new `sql.DB`connection pool.

1. `MaxOpenConns`-- is the box size, you can never have more total connections than this.
2. `MaxIdleConns`-- is the shelf space -- when a task is done, if there is no room on the *idle shelf*-- the connection is thrown away.
3. `ConnMaxIdleTime`-- Is the dust timer -- If a connection sits on the shelf too long without being picked up, discared.
4. `ConnMaxLifetime`-- is the expiration date.

#### Putting it into practice

1. As rule of thumb, you should explicitly set a `MaxOpenConns`value. This should be comfortably below any hard limits on the number of connections imposed by your dbs and infrastructure.
2. In general, higher `MaxOpenConns`and `MaxIdleConns`values will lead to better performance. But the returns are diminishing.
3. `ConnMaxIdleTime`-- Is the *dust timer*.

| **Configure parameters** | **Recommended settings**                                     | **Core purpose**                                             |
| ------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| **`MaxOpenConns`**       | **Explicit setting** (25 in this example)                    | Prevent the number of connections from exceeding the maximum database capacity and use it as a basic traffic throttling method. |
| **`MaxIdleConns`**       | **Consistent with or slightly lower than the maximum number of connections** (25 in this case) | Reduce the overhead of frequently creating and destroying connections and improve performance, but avoid wasting resources due to oversized pools. |
| **`ConnMaxIdleTime`**    | **Set a reasonable time limit** (15 minutes in this case)    | Automatically clean up long-term inactive connections, reducing resource usage and avoiding potential connection failures. |
| **`ConnMaxLifetime`**    | **It can usually be set to unlimited**                       | Unless the database has a hard lifecycle mandatory, there is no need to force new connections frequently. |

##### Configuring the connection pool

Rather than hard-coding these settings, in the `main.go`file to accept them as command line flags. For the command-line flag for the `ConnMaxIdleTime`value is particular interesting, cuz we want it to convey a duration of time, like 5s or 10m. To assist with this we can use the `flag.DurationVar()`function to read in the command-line flag value. Fore:

```go
db   struct {
    dsn          string
    maxOpenConns int
    maxIdleConns int
    maxIdleTime  time.Duration
}

// in the main() func
flag.IntVar(&cfg.db.maxOpenConns, "db-max-open-conns", 25, "Database max open connections")
flag.IntVar(&cfg.db.maxIdleConns, "db-max-idle-conns", 25, "Database max idle connections")
flag.DurationVar(&cfg.db.maxIdleTime, "db-max-idle-time", 15*time.Minute, "Database max connection idle time")
```

#### SQL Migrations

Go back to sth a bit more concrete and tangible in this next section of the book, and take steps to create a movie table in our `greenlight`dbs. To do this, just simply use the PSQL tool.

Working with SQL migrations -- 

```sh
migrate create -seq -ext=.sql -dir=./migrations create_movies_table
```

For the `migrations/00001_create_movies_table_up.sql`just like:

```sql
CREATE TABLE IF NOT EXISTS movies (
    id bigserial PRIMARY KEY,
    created_at timestamp(0) with time zone NOT NULL DEFAULT NOW(),
    title text NOT NULL,
    year integer NOT NULL,
    runtime integer NOT NULL,
    genres text[] NOT NULL, -- Has the type which is an array of zero-or-more text values.
    version integer NOT NULL DEFAULT 1
);
```

Note that Working with `NULL`values in Go can be awkward, and where possible it’s easiest to just set `NOT NULL`constraints on every table column along with appropriate `DEFAULT`values.

