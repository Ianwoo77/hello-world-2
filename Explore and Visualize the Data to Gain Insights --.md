# Explore and Visualize the Data to Gain Insights -- 

Put the test set aside and you are only exploring the training set.

```python
from zlib import crc32

def is_id_in_test_set(identifier, test_ratio):
    return crc32(np.int64(identifier)) < test_ratio * 2**32

def split_data_with_id_hash(data, test_ratio, id_column):
    ids = data[id_column]
    in_test_set = ids.apply(lambda id_: is_id_in_test_set(id_, test_ratio))
    return data.loc[~in_test_set], data.loc[in_test_set]
```

This code implements a hashing-based method of deterministic data set partitioning. In machine learning, usually need to divide data into training sets and tests sets. This code solves this problem -- as long as the ID of the sample remains the same, it will always be assigned to the same set.

`is_id_in_test_set()`-- Judgement func -- determines whether a particular ID should go into the test set. For the `crc32()`-- is a cyclic redundancy check alg that generates a 32-bit integer based on the input 2^32-1. And for the `split_data_with_id_hash()`-- Calls above decision logic for each value in the ID column to generate a Boolean sequence.

```python
from sklearn.model_selection import train_test_split
train_set, test_set = train_test_split(housing, test_size=0.2, random_state=42)
```

The `train_test_split`mentioned in the code the most basic tool -- like grabbing 20% out of a box.

- pros -- Simple and fast, suitable for large data sets
- Disadvantages -- Random scraping can lead to sample bias if the data volume is small
- Risk -- have caught a bunch of small apples and not big apple.

Based on the text, *Stratified Sampling* is a data sampling method used to avoid *sampling bias*. Its core purpose is to ensure the sampled dataset is highly consistent with the original complete dataset in terms of distribution ratio of an important feature.

1. *Startification* -- Divide the entire population into multiple subgroups with similar characteristics and dissimilar disintersections, called *strata*.
2. Proportional Sampling -- The appropriate number of samples is taken from each *layer* to ensure that each layer accounts for exactly the same proportion of the final sample as they do in the original population.

Fore, *median income* is an extremely important feature for predicting house prices. If just *randomly* divide the training set and set the test set with pure `train_test_split()`, the test set may miss high-income or low-income people, resulting in inaccurate model evaluation.

Namely, in machine learning, *pure random sampling* is dangerous when your dataset is not large enough, or when the distribution of a feature is extremely unbalanced.

```python
housing["income_cat"] = pd.cut(housing["median_income"],
                               bins=[0., 1.5, 3.0, 4.5, 6., np.inf],
                               labels=[1, 2, 3, 4, 5])

housing["income_cat"].value_counts().sort_index().plot.bar(rot=0, grid=True)
plt.xlabel("Income category")
plt.ylabel("Number of districts")
save_fig("housing_income_cat_bar_plot")  # extra code
plt.show()
```

To be precise, the `split()`method yields the training and test *indices*, not the data itself, having multiple splits can be useful if you want to better estimate the performance of your model. Fore:

using `StratifiedShuffleSplit`-- 

```python
from sklearn.model_selection import StratifiedShuffleSplit

# 1. 实例化一个分层划分器：划分10次，测试集占20%，随机种子42
splitter = StratifiedShuffleSplit(n_splits=10, test_size=0.2, random_state=42)
strat_splits = []

# 2. 核心逻辑：基于 "income_cat"（收入类别）进行分层划分
for train_index, test_index in splitter.split(housing, housing["income_cat"]):
    # 3. 通过索引提取真实数据
    strat_train_set_n = housing.iloc[train_index]
    strat_test_set_n = housing.iloc[test_index]
    # 4. 将划分好的数据集存入列表
    strat_splits.append([strat_train_set_n, strat_test_set_n])
```

Why divide 10 times -- If only want one training set and one set, 1 time is enough, however, sometimes in order to evaluate the model more accurately, need to divide the data multiple times to test it repeatedly.

And cuz in practice, we usualy only need to divide a hierarchical dataset once, Scikit-learn provide a shortcut.

```python
strat_train_set, strat_test_set = train_test_split(
    housing, test_size=0.2, stratify=housing["income_cat"], random_state=42)
```

```python
def income_cat_proportions(data):
    return data["income_cat"].value_counts() / len(data)

train_set, test_set = train_test_split(housing, test_size=0.2, random_state=42)

compare_props = pd.DataFrame({
    "Overall %": income_cat_proportions(housing),
    "Stratified %": income_cat_proportions(strat_test_set),
    "Random %": income_cat_proportions(test_set),
}).sort_index()
compare_props.index.name = "Income Category"
compare_props["Strat. Error %"] = (compare_props["Stratified %"] /
                                   compare_props["Overall %"] - 1)
compare_props["Rand. Error %"] = (compare_props["Random %"] /
                                  compare_props["Overall %"] - 1)
(compare_props * 100).round(2)
```

Won’t use the `income_cat`column again, so might as well drop it. Spent quite a bit of time on test set generation for a good reason -- this is an often neglected but critical part of a machine learning proj.

##### Visualizing Geographical Data

Cuz the dataset includes geographical info -- it is a good idea to create a scatterplot of all districts to visualize the data.

```python
housing.plot(kind="scatter", x="longitude", y="latitude", grid=True, alpha=0.2)
save_fig("better_visualization_plot")  # extra code
plt.show()
```

Tells U that the housing prices are very much related to the location and to the population density, as U probably knew already -- A clustering algorithm should be useful for detecting the main cluster and for adding new features.

```python
housing.plot(kind="scatter", x="longitude", y="latitude", grid=True,
             s=housing["population"] / 100, label="population",
             c="median_house_value", cmap="jet", colorbar=True,
             legend=True, sharex=False, figsize=(10, 7))
save_fig("housing_prices_scatterplot")  # extra code
plt.show()
```

Fore, in the task of predicting house prices, need to find out which characteristics have the greatest impact on house prices. Fore -- Calculating the Pearson Correlation Coefficient -- Since the dataset is not too large, can directly use the `corr()`by Pandas to calculate the standard correlation coefficient between the two of all numerical attributes.

```python
corr_matrix = housing.corr(numeric_only=True)
corr_matrix["median_house_value"].sort_values(ascending=False)
```

And another way to check for correlation between attributes is to use the Pandas `scatter_matrix()`func, which plots every numerical attribute against every other numerical attributes. At the diagonal position, the horizontal and vertical axes meet the *same variable* -- If draw a scatter plot of a variable with yourself, all the points in the graph will fall on y=x this perfect 45-degree diagonal line. Since there was no point in comparing themselves, the Pandas developers decided to use this position to show the distribution of data for this single variable.

## Add constraint

While are at it, also create a second pair of migration files containing `CHECK`constraints to enforce some of business rules at the dbs-level.

```sql
ALTER TABLE movies ADD CONSTRAINT movies_runtime_check CHECK (runtime >= 1);
ALTER TABLE movies ADD CONSTRAINT movies_year_check CHECK (year BETWEEN 1889 AND date_part('year', now()));
ALTER TABLE movies ADD CONSTRAINT genres_length_check CHECK (array_length(genres, 5) BETWEEN 1 AND 5);
```

#### Executing the migrations

```sh
migrate -path=./migrations -database=$GREENLIGHT_DB_DSN up
```

Migrating to a specific version -- As an alternative to looking at the `schema_migrations`table, fore -- 

```sh
migrate -path=./migirations -database=$EXAMPLE_DSN down 1
```

Personally, generally prefer to use the `goto`command to perform roll-backs and reverse use of the `down`command for rolling-back *all migrations* like -- 

##### Fixing errors in SQL migrations -- 

It’s important to talk about happens when U make a syntax error in your SQL migration files, cuz the behaivor of the `migrate`tool can be a bit confusing to start with -- When run a migration that contains the number of failed migration and the dirty field will be set to `true`. like:

```sh
migrate -path=./migrations -database=$EXAMPLE_DSN force 1
```

### CRUD operations

Going to force on building up the functionality for CRUD -- back to internal/data/movies.go file and create a `MovieModel`struct type and some placeholder methods for performing basic -- 

```go
type MovieModel struct {
	DB *sql.DB
}
```

As an additional step, are going to wrap our `MovieModel`in a parent `Models`struct -- Doing this is totally optional, but it has the benefit of giving you a convenient single container which can hold and represent all your dbs models as your app grows.

```go
var (
	ErrRecordNotFound = errors.New("record not found")
)

type Models struct {
    Movies MovieModel
}

func NewModels(db *sql.DB) Models {
    return Models {
        Movies: MovieModel {DB: db},
    }
}
```

In the `main.go`file like:

```go
app := &application{
    config: cfg,
    logger: logger,
    models: data.NewModels(db),
    //...
}
```

#### Creating a new Movie

Begin with the `Insert()`method of our dbs model and update this to create a new record in our `movies`table.

```sql
INSERT INTO movies(title, year, runtime, genres)
VALUES ($1, $2, $3, $4)
RETRUNING id, created_at, version
```

There are few things about this query which warrant a bit of explanation -- 

- Uses `$N`notation to represent *placeholder parameter* for the data that we want to insert in the `movies`table. Every time that U pass untrusted input data from a client to a SQL dbs it’s important to use placeholder parameters to help prevent SQL injection attacks.
- Then only inserting values for `title, year, runtime`and `genres`-- And the remaining columns in the `movie`will be filled with *system-generated* values at the moment of insertion -- the `id`will be an auto-incrementing integer, and the `created_at`and `version`values will default to the current time and 1 respectively.
- At the end of the query we have a `RETURNING`clause -- this is a PostgreSQL-specific clause.

For the PostgreSQL, then would use Go’s `Exec()`method to execute an `INSERT`statement against a dbs table.

```go
func (m MovieModel) Insert(movie *Movie) error {
	query := `
		INSERT INTO movies (title, year, runtime, genres)
		VALUES ($1, $2, $3, $4)
		RETURNING id, created_at, version`

    // Notice through pq.Array() adapter func before executing the SQL query
	args := []any{movie.Title, movie.Year, movie.Runtime, pq.Array(movie.Genres)}

	// Create a context with 3s timeout.
	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()
	return m.DB.QueryRowContext(ctx, query, args...).Scan(&movie.ID, &movie.CreatedAt, 
                                                          &movie.Version)
}
```

And cuz the `Insert()`method signature takes a `*Movie`pointer as the parameter, when call `Scan()`to read in the syste-generated data updating values at the location the parameter points to.

Hooking it up to our API handler -- 

```go
func (app *application) createMovieHandler(w http.ResponseWriter, r *http.Request) {
	var input struct {
		Title   string       `json:"title"`
		Year    int32        `json:"year"`
		Runtime data.Runtime `json:"runtime"`
		Genres  []string     `json:"genres"`
	}

	err := app.readJSON(w, r, &input)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	movie := &data.Movie{
		Title:   input.Title,
		Year:    input.Year,
		Runtime: input.Runtime,
		Genres:  input.Genres,
	}

	v := validator.New()

	data.ValidateMovie(v, movie)

	if !v.Valid() {
		app.failedValidationResponse(w, r, v.Errors)
		return
	}

	err = app.models.Movies.Insert(movie)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	headers := make(http.Header)
	headers.Set("Location", fmt.Sprintf("/v1/movies/%d", movie.ID))

	err = app.writeJSON(w, http.StatusCreated, envelope{"movie": movie}, headers)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}
```

```sh
curl -i -d "$BODY" localhost:4000/v1/movies
```

##### Additional Information -- 

A nice feature of the PostgreSQL placeholder parameter `$N`notation is that U can use the same parameter value in multiple places in your SQL statement. Fore, it’s perfectly acceptable to write code like this -- 

#### Fetching a Movie

Begin in our dbs model here, and start by updating the `Get()`method to execute the following SQL query -- 

```go
func (m MovieModel) Get(id int64) (*Movie, error) {
	if id == 0 {
		return nil, ErrRecordNotFound
	}

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	query := `
		SELECT  id, created_at, title, year, runtime, genres, version
		FROM movies
		WHERE id = $1`
    //..
    err := m.DB.QueryRowContext(ctx, query, id).Scan(
		&movie.ID,
		&movie.CreatedAt,
		&movie.Title,
		&movie.Year,
		&movie.Runtime,
		pq.Array(&movie.Genres),
		&movie.Version,
    )
    
    // otherwise, return a pointer to the Movie struct.
    return &movie, nil
}
```

#### Updating a Movie

In this will continue building up our app and add a brand-new endpoint which allows clients to *update data for specific movie*. More precisely, setup the endpoint so that a client can edit the `title, year, runtime`and `genres`values for a movie, in our project the `id`and `created_at`values should never change once they’ve been created, and the `version` isn’t something that the client should control, so we won’t allow those fileds to be edited. 

```sql
UPDATE movies
set title=$1, year=$2, runtime=$3, genres=$4, version=version+1
where id=$5
RETURNING version
```

Returns a single row of data so also need to use Go’s `QueryRow`method to execute it. If you’re following along, head back to your `internal/data/movies.go`file and fill in the `Update()`method like -- 

```go
func (m MovieModel) Update(movie *Movie) error {
    query := `UPDATE ... RETURNING version`
    args := []any {
        movie.Title,
        movie.Year,
        pq.Array(movie.Genres),
        movie.ID,
    }
    return m.DB.QueryRow(query, args...).Scan(&movie.Version)
}
```

It’s important to emphasize that -- just like our `Insert()`method -- the `Update()`method takes a pointer to a `Movie`struct as the input parameter and mutates it in-place again.

# Using the `effect`hook

- A function that executes the effect; at a minimum, this function runs each time the component is rendered.
- An optional array of *dependencies* that cause the effect function to return when changed.

```tsx
function SomeComponent() {
    function someEffect() {
        console.log("Some effect");
    }
    useEffect(someEffect);
    return ...
}
```

Often, an anonymous arrow function is used for the effect function -- Here is the same example but with an anonymous effect function instead -- 

```tsx
function SomeComponent() {
    useEffect(()=> {
        console.log("Some effect");
    });
    return...
}
```

Here is another example of an effect -- 

```tsx
function SomeOtherComponent({search}: {search:string}) {
    useEffect(()=> {
        console.log("An effect dependent on a search prop, search");
    }, [search]);
    return ...
}
```

#### The rules of Hooks

There are some rules that most React hooks -- including `useEffect`, must obey -- 

- A Hook can only be called at the top level of a function component, so, a hook can’t be called in a loop or a nested such an event handler.
- A Hook can’t be called conditionally.
- A Hook can only be used in function components and not class components.

```tsx
export function AnotherComponent() {
    function handleClick() {
        useEffect(()=>{
            console.log("Some effect");
        });
    }
    return(
    	<button onClick={handleClick}>Cause effect</button>
    )
}
```

This is a violation cuz `useEffect`is called in a handler function rather then the top level. A corrected version is as follows -- like:

```tsx
export function AnotherComponent() {
    const [clicked, setClicked] = useState(false);
    useEffect(()=> {
        if(clicked) {
            console.log("Some effect");
        }
    }, [clicked]);
    function handleClick() {
        setClicked(true);
    }
    return (<button onClick={handleClick}>Cause effect</button>)
}
```

`useEffect`has been lifted to the top level and now depends on the `clicked`state that is set in the handler function.

#### Effect Cleanup

An effect can return a function that performs cleanup logic when the component is unmounted -- Cleanup logic ensures nothing is left that could cause memory leak -- 

```tsx
function ExampleComponent({onClickAnywhere}: {onClickAnywhere:()=>void}) {
    useEffect(()=> {
        function handleClick() {
            onClickAnywhere();
        }
        document.addEventListener("click", handleClick);
    });
    return ...
}
```

The preceding effect function attaches an event handler to the `document`element. The event handler is never deteached -- though, so multiple event handlers will become attached to the `document`element as the effect is rerun. This problem is resolved by returning a `cleanup`function that detaches the event handler -- as follows -- 

```tsx
function ExampleComponent( ... ) {
    useEffect(() => {
        function handleClick() {
        onClickAnywhere();
        }
        document.addEventListener(“click”, handleClick);
        return function cleanup() {
        	document.removeEventListener(“click”, handleClick);
    };
        return ...
});
```

#### Creating the project -- 

A common use of the effect Hook is fetching data -- carry out the following steps to implement an effect that fetches a person’s name -- just like:

```tsx
type Person={
    name:string;
}

export function getPerson(): Promise<Person> {
    return new Promise<Person>((resolve)=>{
        setTimeout(()=>resolve({name:"Bob"}), 1000)
    });
}
```

The function asynchronously return an object `{name: "Bob"}`, after a second has elasped. Notice the type annotation for the return type -- `Promise<Person>`-- the `Promise`type represents a Js promise.

```tsx
export function PersonScore() {
    const [name, setName] = useState<string | undefined>();
    const [score, setScore] = useState(0);
    const [loading, setLoading] = useState(true);
    useEffect(() => {
        getPerson().then((person)=> {
            setLoading(false);
            setName(person.name);
            console.log('State values:', loading, name);
        });
    }, []);
    // or using:
    useEffect(async ()=> {
        const person=await getPerson();
        console.log(person);
    }, []);
    if (loading) {
        return <div>Loading...</div>;
    }

    return (
        <div>
            <h3>{name}, {score}</h3>
            <button onClick={()=> setScore(score + 1)}>+</button>
            <button onClick={()=> setScore(score - 1)}>-</button>
            <button onClick={()=> setScore(0)}>Reset</button>
        </div>
    )
}
```

#### Understanding `useReducer`

`useReducer`is an alternative, more complex, method of managing state, it uses a `reducer`function for state changes, which takes in the current state value and returns the new state value -- like:

```tsx
const [state, dispatch] = useReducer(reducer, initialState);
```

So, `useReducer()`takes in a reducer function and the initial state value as parameters -- it then returns a tuple containing the current state value and a function to `dispatch`state changes. For the `dispatch`function, should takes in an argument that describes the change. This object is often referred to as an action -- an example `dispatch`call is as follows -- `dispatch({type:'add', amount:2})`

For this, there is no defined structure for an action, but it is just *common* practice for it to contain a *property*, such as `type`, to specify the type of change. Other properties in the action can vary depending on the type of change. Then for the `reducer`should be like:

```tsx
function reducer(state: State, action: Action): State {
    switch(action.type) {
        case 'add':
            return {
                ...state, total: state.total+action.amount
            };
        case '...':
            //...
        default:
            return state;
    }
}
```

The reducer function usually contains a `switch`statement based on the action type, Each `switch`branch makes the required changes to the state and returns the updated state. Also note that can be explicitly defined in its generic parameter as follows:

```tsx
const [state, dispatch]= useReducer<Reducer<State, Action>>(reducer, initialState);
```

`Reducer`is a std React type that has generic paramerters for the type of state and the type of action.

```tsx
type State = {
    name: string | undefined;
    score: number;
    loading: boolean;
}

type Action =
    | { type: 'initialize', name: string }
    | { type: 'increment' }
    | { type: 'decrement' }
    | { type: 'reset' };

function reducer(state: State, action: Action): State {
    switch (action.type) {
        case 'initialize':
            return {
                name: action.name,
                score: 0,
                loading: false
            };
        case 'increment':
            return {
                ...state,
                score: state.score + 1
            };
        case 'decrement':
            return {
                ...state,
                score: state.score - 1
            };
        case 'reset':
            return {
                ...state,
                score: 0
            }
    }
}
```

using `useReducer`-- like:

```tsx
export function PersonScoreReducer() {
    const [{name, score, loading}, dispatch] = useReducer(reducer, {
        name: undefined,
        score: 0,
        loading: true
    });
    useEffect(() => {
        getPerson().then(({name}) => {
            dispatch({type: 'initialize', name});
        })
    }, []);

    useEffect(() => {
        if (!loading)
            addButtonRef.current?.focus();
    }, [loading]);

    return (
        <div>
            <h3>{name}, {score}</h3>
            <p>{expensiveCalculation}</p>
            <button onClick={() => dispatch({type: 'increment'})}>+</button>
            <button
                ref={addButtonRef}
                onClick={() => dispatch({type: 'decrement'})}>-
            </button>

            <Reset onClick={handleResetMemoized}/>
        </div>
    )
}
```

That completes our exploration of the `useReducer`hook. it is more useful for complex state management.
