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