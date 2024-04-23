# Git Truorial

```sh
git config --list # show
git config --global user.name "yourname"
git config --global user.email "test@w3schools.com"

# initialize Git
git init

# delete dirctory recur and force
rmdir -rf myproject/

# add some file
git status
```

Now Git is aware of the file, but has not added it to our repository. And files in your Git repository folder can be one of 2 states -- *Tacked* and *Untracked*. When first add files to an empty repository, they are all untracked.

### Git Staging Environment

**Staged** files are files that are ready to be **committed** to the repository you are working on.

```sh
git add index.html
# now the file has been added to the staging environment
```

add a css file like:

```css
body {
    background-color: lightblue;
}

h1 {
    color: navy;
    margin-left: 20px;
}
```

Then update the index.html file like: Then add all files in the current directory to the staging environment like:

```sh
git add --all # git add -A
```

### Git commit

Since we have finished our work, we are ready move from *stage* to *commit* for repo. Adding commits keep track of our progress and changes as we work. Git considers each `commit`change point or *save point*. Should always include a *message*. like:

```sh
git commit -m "First release of Hello World"
# without stage
git status --short # see changes in a more compact way
git commit -a -m "A new line"

# git log to view the commits for a repo like:
git log
```

## Pandas

Imports the CSV file’s contents into an object called a `DataFrame`. Think of an object as a container for storing data. Among fore 5 columns, Rank and Title are the two best options. like:

```python
pd.read_csv('movies.csv', index_col='Title')
```

Next, assign the `DataFrame`to `movies`variable so that we can reference it elsewhere in our program.

```python
len(movies) # how many rows
movies.shape
movies.size # total number of cells
movies.dtypes
movies.iloc[499]
```

Returns a new obj here called a `Series`-- 1D labeled array of values. `movies.loc['Forrest Gump']`, And index lables can contain duplicates -- two movies in the DF have the title 101 Dalmatians. FORE: `movies.loc['101 Dalmatians']`, returns a DF.
`movies.sort_values(by='Year', ascending=False).head()` Can also sort by values across *multiple columns* -- sort by Studio column’s values and then by Year.
`movies.sort_values(by=['Studio', 'Year']).head()`

The operations performed so far return *new* `DataFrame`objects.

### Couting values in a Series -- 

`movies.loc[:, 'Studio']`and `movies['Studio']` If a Series has a large umber of rows, pandas truncates. Isolated the `Studio`column, Can count each unique value’s number of occurences. like:

```python
movies['Studio'].value_counts().head(10)
```

The return value above is yet another `Series`object.

### Filtering a column by one or more criteria 

Often want to extract a subset of rows based on one or more criteria. Like:

```python
movies[movies['Studio']=='Universal']
released_by_universal = (movies['Studio']=='Universal')
movies[released_by_universal]

# can also filter rows by multiple criteria like:
released_by_universal = movies["Studio"] == "Universal"
released_in_2015 = movies["Year"] == 2015
movies[released_by_universal & released_in_2015]
# or 
movies[released_by_universal | released_in_2015]
```

Pandas provides additional ways to filter a `DataFrame`-- can target column values less than or greater than a specific vlaue. FORE, here target movies released before 1975.

```python
before_1975 = movies['Year']<1975
movies[before_1975]
```

Can also specify a range between which all values must fall, the next example pulls out movies released between 1983 and 1986 like:

```python
mid_80s = movies['Year'].between(1983, 1986)
movies[mid_80s]
```

Can also use the `DataFrame`index to filter rows. lowercases the movie titles in the index and finds all movies with the word in their title. like:

```python
movies["Gross"] = (
    movies["Gross"]
    .str.replace("$", "", regex=False)
    .str.replace(",", "", regex=False)
    .astype(float)
)
studios= movies.groupby('Studio')
studios['Gross'].count().head()
studios['Year'].count().sort_values(ascending=False).head()
stuidos['Gross'].sum().sort_values(ascending=False).head()
```

```html
<body class="p-2">
{{block "body" .}} Content Goes Here {{end}}
</body>
```

### Loading the Templates

```go
var responses = make([]*Rsvp, 0, 10)
var templates = make(map[string]*template.Template, 3)

func loadTemplates() {
	templateNames := [5]string{"welcome", "form", "thanks", "sorry", "list"}
	for index, name := range templateNames {
		t, err := template.ParseFiles("layout.html", name+".html")
		if err == nil {
			templates[name] = t
			fmt.Println("Loaded template", index, name)
		} else {
			panic(err)
		}
	}
}

func main() {
	loadTemplates()
}
```

### Creating the Http Handlers and Server

The Go std lib includes built-in support for creating HTTP servers and handling HTTP requests.

```go
func welcomeHandler(writer http.ResponseWriter, request *http.Request) {
	templates["welcome"].Execute(writer, nil)
}

func listHandler(writer http.ResponseWriter, request *http.Request) {
	templates["list"].Execute(writer, responses)
}

func main() {
	loadTemplates()
	http.HandleFunc("/", welcomeHandler)
	http.HandleFunc("/list", listHandler)

	err := http.ListenAndServe(":5000", nil)
	if err != nil {
		fmt.Println(err)
	}
}
```

```go
func formHandler(writer http.ResponseWriter, request *http.Request) {
	if request.Method == http.MethodGet {
		templates["form"].Execute(writer, formData{
			&Rsvp{}, []string{},
		})
	}
}
```

There is no data to use when responding to GET requests. Go doesn’t have a `new`keyword, and values are created using braces -- with default values being used for any field for which a value is not specified.

```go
templates["form"].Execute(writer, formData{
    Rsvp: &Rsvp{}, Errors: []string{},
})
```

Then for the POST requests, and, read the data that the user has entered into the form.