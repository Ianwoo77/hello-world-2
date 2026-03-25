## Full-Text Search

In this chapter we are going to make our movie title filter easier to use by adapting to support *partial matches*. Rather than requiring a match one the full title. Fore `title=breakfast`. There are  a few different ways we could implement this feature in our codebase -- but an effective and intuitive method is to leverage PSQL’s *full-text* search functionality, which allows U to perform *natrual language* searches on text fields in your dbs.

PostgreSQL full-text search is a powerful and highly-configured tool, and explaining how it works and the available options in full could easily take up a whole hook in itself.

```sql
SELECT id, created_at, title, year, runtime, genres, version
FROM movies
WHERE (to_tsvector('simple', title) @@ plainto_tsquery('simple', $1) OR $1 = '')
AND (genres @> $2 OR $2 = '{}')
ORDER BY id
```

That looks pretty complicated at first glance, let’s break it down and explain what is going on -- `to_tsvector('simple', title)`function takes a movie and splits it into *lexemes*. The `plainto_tsquery('simple', $1)`function takes a search values and turns it into a formatted query term that PostgreSQL full-text search can understand. It normalizes the search Value -- strips any special characters, and insert and operator `&`between the words.

For the `@@`operator is the matches operator. In the statement we are using it to check whether the generated query term matches the lexemes. To continue the example, the query term `‘the’ & 'club'`will match rows which contain both lexemes `the`and `club`.

#### Adding indexes

To keep our SQL query performing quickly as the dataset grows, it’s sensible to use indexes to help avoid full table scans and avoid generating the lexemes for the `title`field every time the query is run. In our cases it makes sense to create *GIN `index`*on both the `genres`field and the lexems generated `to_tsvector()`, both which are used in the `WHERE`clause of the SQL query.

```sh
 migrate create -seq -ext .sql -dir ./migrations add_movies_indexes
```

```sql
CREATE INDEX IF NOT EXISTS movies_title_idx ON movies USING GIN (to_tsvector('simple', title));
CREATE INDEX IF NOT EXISTS movies_genres_idx ON movies USING GIN (genres);
```

`GIN`-- Generalied Inverted Index is essentially the *index of an index* it’s designed to handle data types where a single column value contains multiple search terms, like arrays of full-text search vectors.

1. Full-Text search index:

   `CREATE INDEX IF NOT EXISTS movies_title_idx ON movies USING GIN (to_tsvector('simple', title));`-- 

   - Instead of searching for an extract string, this converts the `title`into a `tsvector`.
   - If a user searches for `Star`-- the GIN index allows Postgres to instantly find every title containing that word without scanning every row in the dbs.
   - By using `simple`-- you are telling Posgres to look for exact matches rather than using *stemming*.

2. Array/multivalue index -- `CREATE INDEX IF NOT EXISTS movies_genres_idx ON movies USING GIN (genres);`-- 

   - The logic -- Assuming `genres`is an array -- 
   - The benefit -- this index maps each individual genre to the rows it appears in.
   - The Query -- this makes operators like `@>`contains `&&`incredibly fast.

| **Characteristics** | **B-Tree (Standard)**                          | **GIN (Generalized Inverted)**                               |
| ------------------- | ---------------------------------------------- | ------------------------------------------------------------ |
| **Best For**        | Unique values, sorting, ranges (`<`, `>`, `=`) | Arrays, JSONB, Full-text search                              |
| **Speed**           | Extremely fast for single lookups              | Slightly slower to update, but lightning fast for complex lookups |
| **Size**            | Generally smaller                              | Can grow quite large depending on the number of unique "keys" |

#### Non-simple configuration and more information

As mentioned above, Can also use a language-specfic configuration for full-text searches instead of the `simple`configuration that we are currently using. When U create lexemes or query terms using a language-specifc configuration -- will strip out common words for the language and perform word stemming.

```sql
CREATE INDEX IF NOT EXISTS movies_title_zh_idx 
ON movies 
USING GIN (to_tsvector('chinese', title));
```

##### Using `STRPOS`and `ILIKE`

If don’t want to use full-text search for the partial movie lookup -- some alternatives are the PSQL `STRPOS()`function and `ILIKE`operator. The PostgreSQL `STRPOS()`function allows U to check for the existence of a substring in a particular dbs field. could use it in our SQL query like this.

```sql
SELECT id, created_at, title, year, runtime, genres, version
FROM movies
WHERE (STRPOS(LOWER(title), LOWER($1)) > 0 OR $1 = '')
AND (genres @> $2 OR $2 = '{}')
ORDER BY id
```

##### How it works --

- `STRPOS(a, b)`returns the 1-based index of substring `b`insdie string `a`.
- If `b`is not found, it returns 0
- If `STRPOS(...)>0`means substring exists.

##### `ILIKE`with wildcards

`ILIKE`is case-insenstive pattern matching -- `title ILIKE $1`.

#### Sorting Lists

Now update the logic for our `GET /v1/movies`endpoint so that the client can control how the movies are sorted in the JSON response -- We want to let the client control the sort order via a query string parameter in the format `sort={-}{field_name}`where the optional `-`character is used to indicate a descending sort order.

```go
// Sort the movies on the title field in ascending alphabetical order.
/v1/movies?sort=title

// Sort the movies on the year field in descending numerical order.
/v1/movies?sort=-year
```

Behind the scenes we will want to translate this into an `ORDER BY`clause in our SQL Query -- so that a query string parameter like `sort=-year`would result in SQL query like this -- 

```sql
SELECT id, created_at, title, year, runtime, genres, version
FROM movies
WHERE (STRPOS(LOWER(title), LOWER($1)) > 0 OR $1 = '')
AND (genres @> $2 OR $2 = '{}')
ORDER BY year DESC -- Order the result by descending year
```

#### Implementing sorting

To get the dynamic sorting working, let’s begin by updating our `Filters`struct to include some `sortColumn()`and `sortDirection()`helpers that transform a query string value into values we can use in our SQL query.

```go
type Filters struct {
	Page         int
	PageSize     int
	Sort         string
	SortSafeList []string
}

// sortColumn checks that the client-provided Sort field matches one of the entries in our safelist
// and if it does, extract the column name from the Sort field by stripping the leading
// hyphen character (if one exists).
func (f Filters) sortColumn() string {
	for _, safeValue := range f.SortSafeList {
		if f.Sort == safeValue {
			return strings.TrimPrefix(f.Sort, "-")
		}
	}
	panic("unsafe sort parameter " + f.Sort)
}

func (f Filters) sortDirection() string {
	if strings.HasPrefix(f.Sort, "-") {
		return "DESC"
	}
	return "ASC"
}
```

Notice that the `sortColumn()`function is constructed in such a way that it will `panic`if the client-provided `Sort`value doesn’t match one of the entires in our safelist. In theory this shouldn’t happen -- the `Sort`value should have already been checked by calling the `ValidateFilters()`function.

## Routes

```tsx
export default function Home() {
    return (<main>
        <h2>
            Welcome to my blog!
        </h2>
    </main>);
}

// note that the name is index.tsx
import { posts } from '@/data/posts';
export default function Posts() {
    return (
        <main>
            <h2>Posts</h2>
            <ul>
                {posts.map((post) => (
                    <li key={post.id}>
                        <span>{post.title}</span>
                        <p>{post.description}</p>
                    </li>
                ))}
            </ul>
        </main>
    );
}
```

#### Creating navigation

`Next.js`has two ways to implement navigation, which we will cover in this section -- As part of the learning process, we will update the blog posts to include links to the associated `Post`page. The `Link`component is the recommended way to perform navigation in Next.js -- 

```tsx
<li key={post.id}>
    <Link href={`/posts/${post.id}`}>
        {post.title}
    </Link>
    <p>{post.description}</p>
</li>
```

##### Using `useRouter`

The Next.js `useRouter`hook allows programmatic navigation -- unlike `Link`, it can’t be used in an RSC, to the consuming component must be a clent component -- 

- `push`-- Perform client-side navigation, adding a new entry to the browser history
- `replace`-- Perform client-side navigation, without adding a new entry to the browser history.
- `refresh`-- Refreshes the current route without losing any state.

```tsx
function SomeComponent() {
    const router = useRouter();
    
    function handleClick() {
        if(someClick()) {
            router.push('/some-path');
        }else
            router.push('/some-other-path');
    }
    return <button onClick={handleClick}>Action</button>
}
```

- The `useRouter()`hook is called at the start of the component and assigned to a `router`variable, all the routing functions are available in the `router`variable
- The router’s `push`function is called in the button-click handler with the path being passed.

#### Creating `Shared`layout

In this, will create a header for our app containing links to the `Home`and `Posts`pages -- will use the shared layout capabilities of Next.js to implement this.  Just like:

```tsx
export default function RootLayout({children}: {...}) {
    return (
    	//...
        {children}
    )
}
```

##### Creating a header

We will create a `Header`component in our app containing to the `Home`and `Page`pages. Will then add `Header`to the `RootLayout`to visible in all routes -- 

1. Create a `component`folder in the `src`folder and then a file called `Header.tsx`inside it.  Add the following content inside the `Header.tsx`.

2. In the new `document.tsx`file just like:

   ```tsx
   export default function Document() {
       return (
           <Html lang="en">
               <Head/>
               <body className="antialiased">
               <Header/>
               <Main/>
               <NextScript/>
               </body>
           </Html>
       );
   }
   ```

3. We are going to improve the styling of the header links a little -- style the active link so that it stands out. Will use a hook called `usePathname`from Next.js to get the active path to check against the link’s path to determine whether it is active. To start with, make the following a highlighted changes in `Header.tsx`like:
