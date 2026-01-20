# Trainging Supervision

ML system can be classified according to the amount and type of supervision they get during training.

##### Supervised learning -- 

In Supervised learning, the training set feed to the alg includes the desired solutions -- A typical supervised learning, self-superviesed learning -- semi-supervised learning -- For a typical supervised learning task is classification. The spam filter is good example of this.

```python
from pathlib import Path
import pandas as pd
import tarfile
import urllib.request

def load_housing_data():
    tarball_path = Path("datasets/housing.tgz")
    if not tarball_path.is_file():
        Path("datasets").mkdir(parents=True, exist_ok=True)
        url = "https://github.com/ageron/data/raw/main/housing.tgz"
        urllib.request.urlretrieve(url, tarball_path)
    with tarfile.open(tarball_path) as housing_tarball:
            housing_tarball.extractall(path="datasets")
    return pd.read_csv(Path("datasets/housing/housing.csv"))

housing = load_housing_data()
```

A typcial supervised learning task is classification. The spam filter is a god example of this -- it is trained with many example emails along with their class.

##### Main types of supervised learning

Classification--

1. Goal: predict a category or clsss
2. Example  - is this email smap or not smap, is image a cat or a dog
3. output: DIscrete

Regression -- 

- Goal: predict a continuous numerical value
- Predicating house prices based on square footage.

##### Unsupervised learning -- 

In unsupervised learning, the alg is given data with no labels, the system tries to learn the patterns and structure from the data without any specific guidance -- hidden structures.

1. Clustering - Grouping similar data points together
2. Dimensionality Reduction
3. Association

| Feature        | Supervised Learning                                  | Unsupervised Learning                                        |
| :------------- | :--------------------------------------------------- | :----------------------------------------------------------- |
| **Input Data** | Labeled (Input + Correct Output)                     | Unlabeled (Input only)                                       |
| **Goal**       | Prediction                                           | Discovery / Pattern recognition                              |
| **Feedback**   | Direct feedback (Model knows if it's wrong)          | No feedback (Model finds its own structure)                  |
| **Complexity** | Generally simpler to calculate accuracy.             | Harder to evaluate (no "correct" answer).                    |
| **Use Case**   | Spam filtering, Face recognition, Price forecasting. | Recommendation systems, Anomaly detection, Customer grouping. |

- Use Supervised learning -- if U have a history of data with known outcomes and U want to predict the outcome for new data.
- Use Unsupervised learning -- If have a pipe of raw data you wnt to explore it to see what segments, patterns, or outliers exist.
- Another important unsupervised task is anomaly detetion rule learning, in which the goal is to dig into large amounts of data and discover interesting rel between attributes.

##### Semi-supervised learning

Since labeling data is usually time-consuming and costly, you will often have plenty of unlabeled and a few laeled-- 

- Scenario -- have a small amount labled data and massive amount of unlabeled data
- The Goal -- Use the structure of the unlabled data to improve the model’s performance on the specific task defined by the labeled dta.

How -- 

1. Pseudo-lableing -- The model trains on the small labeled dataset, it then makes predications on the unlabeled data. if the model is very confident about a prediction, it treats that prediction as a fact.
2. Consistency regularization - Hiring a radiologist to label 100000 lung x-Rays is to expensive, instead, the radiologist lables 1000 x-rays...

##### Self- supervised 

The fill-in-the-blank approach -- Self-supervised learning technicaly a subset unsupervised learning, but with a twist, The system creates its won labels from the data itself.

- The scenario, you have massive amounts unlabeled data and Zero labeled data initially.
- The Goal -- To learn Representations - you want the model to understand the context of the data.

##### Reinformcement leanring

Can Observe the environment, select and perfrom actions, and get rewards in return. Fore, many robots implement reinformcement learning alg to learn how to walk.

The Trial and Error Approach -- Think of RL as trining a dog. 

1. Observeration -- The agent looks at the current situation
2. Action -- The agent makes a move
3. Feedback -- the environment reacts.
4. Update -- the agent updtes it stragety to maximize furture rewards.

##### Bench learning -- 

This will generally take a lot of time and computing resources, so it is typically done offline. And in online learning, you train the system incrementally by feeding it data instances sequentially, either individually or in small groups called mini-batches. The system can learn about new data on the fly. On-line learning is useful for systems that needs to adapt to change extremely rapidly. Most importantly, online learning alg can be used to train models on huge datasets that cannot fit in one machine’s memory.

Why use online Learing -- There are two main reasons to use the approach -- 

1. Data is Too big - If you have terabytes of data that physically cannot fit into your computer’s memory -- can’t use batch learning. Online learing allows U to stream the data although the mode like water through a pipe.
2. World is changing -- This is the most common use case, in the real world, data patterns change over time, called concept drift.

| Feature      | Batch Learning (Offline)                       | Online Learning                                          |
| :----------- | :--------------------------------------------- | :------------------------------------------------------- |
| **Training** | Takes hours/days on a static set.              | Continuous, occurring in milliseconds.                   |
| **Updates**  | Requires a full retrain to update.             | Updates instantly with new data.                         |
| **Hardware** | Needs massive memory (RAM).                    | Low memory (process data & discard).                     |
| **Best For** | Stable environments (e.g., Medical diagnosis). | Dynamic environments (e.g., Stock market, Social Media). |
| **Weakness** | Can become outdated quickly.                   | Susceptible to noise and manipulation.                   |

```python
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from sklearn.linear_model import LinearRegression

# Download and prepare the data
data_root = "https://github.com/ageron/data/raw/main/"
lifesat = pd.read_csv(data_root + "lifesat/lifesat.csv")
X = lifesat[["GDP per capita (USD)"]].values
y = lifesat[["Life satisfaction"]].values

# Visualize the data
lifesat.plot(kind='scatter', grid=True,
             x="GDP per capita (USD)", y="Life satisfaction")
plt.axis([23_500, 62_500, 4, 9])
plt.show()

# Select a linear model
model = LinearRegression()

# Train the model
model.fit(X, y)

# Make a prediction for Cyprus
X_new = [[37_655.2]]  # Cyprus' GDP per capita in 2020
print(model.predict(X_new)) # outputs [[6.30165767]]
```

```python
country_stats.plot(kind='scatter', figsize=(5, 3), grid=True,
                   x=gdppc_col, y=lifesat_col)

min_life_sat = 4
max_life_sat = 9

position_text = {
    "Turkey": (29_500, 4.2),
    "Hungary": (28_000, 6.9),
    "France": (40_000, 5),
    "New Zealand": (28_000, 8.2),
    "Australia": (50_000, 5.5),
    "United States": (59_000, 5.3),
    "Denmark": (46_000, 8.5)
}

for country, pos_text in position_text.items():
    pos_data_x = country_stats[gdppc_col].loc[country]
    pos_data_y = country_stats[lifesat_col].loc[country]
    country = "U.S." if country == "United States" else country
    plt.annotate(country, xy=(pos_data_x, pos_data_y),
                 xytext=pos_text, fontsize=12,
                 arrowprops=dict(facecolor='black', width=0.5,
                                 shrink=0.08, headwidth=5))
    plt.plot(pos_data_x, pos_data_y, "ro")

plt.axis([min_gdp, max_gdp, min_life_sat, max_life_sat])

save_fig('money_happy_scatterplot')
plt.show()
```

So another way to generalize from a set of examples is to build a cmodel of these examples and then use that model to make *predictions*.

```python
country_stats.plot(kind='scatter', figsize=(5, 3), grid=True,
                   x=gdppc_col, y=lifesat_col)

X = np.linspace(min_gdp, max_gdp, 1000)
plt.plot(X, t0 + t1 * X, "b")

plt.text(max_gdp - 20_000, min_life_sat + 1.9,
         fr"$\theta_0 = {t0:.2f}$", color="b")
plt.text(max_gdp - 20_000, min_life_sat + 1.3,
         fr"$\theta_1 = {t1 * 1e5:.2f} \times 10^{{-5}}$", color="b")

plt.axis([min_gdp, max_gdp, min_life_sat, max_life_sat])

save_fig('best_fit_model_plot')
plt.show()
```

