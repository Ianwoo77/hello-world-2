# Recover for Pandas

Pandas imports the CSV file’s contents into an object called a `DataFrame`. Think of an object as a container for storing data. like:

```python
pd.read_csv('../pandas-in-action/chapter_01_introducing_pandas/movies.csv',
            index_col='Title')
movies.head(4)
movies.tail(6)
```

`movies.shape` # for the number of rows and columns in the `DataFrame`
`movies.size` # ask for the total number of cells
`movies.iloc[499]`# Pandas returns a new object here called a `Series`, a one-dimensional labled array of values. Think of it as a single column of data with an identifier for each row.
`movies.loc['Forrest Gump']` # can also use an index lable to access a `DataFrame`row.

And Index labels can contain duplicates -- two movies in the `DataFrame`have the title.. like:
`movies.loc['101 Dalmatians']` # just returns two rows `DataFrame`. 

Recommend keeping index labels unique if possible. And the films in the CSV are sorted by values in the Rank column -- what if we wanted to see the 5 movies with the most recent release date -- just like:
`movies.sort_values('Year', ascending=False)`
Can also sort `DataFrame`by values across multiple columns.

```python
movies.sort_values(by=['Studio', 'Year'], ascending=(True, False)).head()
```

Can also sort the index, which is helpful if we want to see the movies in alphabetical order like:
`movies.sort_index(*ascending*=False).head()`
Note that the operations we have performed for return *new* `DataFrame`objects. -- Pandas has not altered the original movies `DataFrame`from the CSV files.

### Counting values

Can just extract a single column of data from a `DataFrame`as a `Series`-- like: Find out which movie studio had the greatest number of highest-grossing film. `movies.loc[...,'Studio']`
`movies['Studio'].value_counts()`

### Filtering a column by one or more criteria

Often want to extract a subset of rows based on one or more criteria.
`movies[movies['Studio']=='Universal']`

And can assign the filtering condition to a variable to provide context for readers like:

```python
released_by_universal = \
    movies['Studio']=='Universal'
```

Can also filter `DataFrame`rows by multiple criteria -- the next example just targets all movies released by Universal studios and released in 2015 like:

```python
released_in_2015 = movies['Year']==2015
movies[released_by_universal & released_in_2015]
```

This previous example includes rows that just satisfied like:

```python
before_1975= movies['Year']<1975
movies[before_1975]
```

Can also specify a range between which all values must fall. The next example pulls out movies released like:

```python
mid_80s= movies['Year'].between(1983, 1986)
movies[mid_80s]
```

Can also use the `DataFrame`index to filter rows. The next lowercases the movie titles in the index and finds all movies with the word `dark`in their title like:

```python
has_dark_in_title = movies.index.str.lower().str.contains('dark')
movies[has_dark_in_title]
```

Notice that pandas finds all movies containing the word dark irrespective of where the text appears in the title.

```go
func main() {
	fmt.Println(rand.Int())
}
```

Untyped constants will be converted only if the value can be represented in the target type. In practice, this means can mix untyped and floating-point number values, but conversions between other.

The `iota`can be used to create a series of successive untyped constants without needing to assign individual values like:

```go
const (
	Watersports= iota
    Soccer
    Chess
)
```

Creates a series of constants, each of which is assigned an integer value, starting at zero.

`go work use .`

### Writing strings

the `fmt`package provides functions for composing and writing strings. The basic functions are like:

- `Fprint(writer, ...vals)` -- this writes out a variable number of args to the specified writer.
- `Fprintln(writer, ...vals)`-- writes out a variable number of args to the specified writer.

### Formatting strings

```go
func main() {
	fmt.Printf("product: %v, Price $%4.2f", Kayak.Name, Kayak.price)
}
```

The template is scanned for *verbs*, which are denoted by the percentage sign, and followed by a format specifier.

- `Sprintf(t, ...vals)`-- returns a string, which is created by processing the template `t`.
- `Printf(t, ...vals)`-- creates a string by processing the template `t` -- the remaining args are used as values for the tempalte verbs. The string is written to the stdout
- `Fprintf(writer, t, ...vals)`-- creates a string by processing the template `t`. The remaining args are used as values for