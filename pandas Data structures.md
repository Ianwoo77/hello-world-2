## pandas Data structures

*Series* and *DataFrame* -- while they are not a universal solution for every problem, they provide a solid foundation for a wide variety of data tasks.

### Series

1d array-like object containing a sequence of values of same type and an associated array of data labels -- Called *indexes* -- like:

```py
obj= pd.Series([4,7,-5,3])
```

The string representation of a `Series`displayed interactively shows the index on the left and the values on the right. Since did not speicfy an index for the data, a default one consisting the just the intergers 0 through N-1 is created. U can get the array representation and index object of Series via its `array`and `index`attributes respectively.

And the result `.array`attr is a `PandaArray`which usually just wraps a Numpy array but can also contain special extension array bytes which .. like:

`obj2 = pd.Series([4,7,-5,3], index=list('dbac'))`

And, using just Numpy functions or Numpy-like operations, such as filtering with a Boolean array, scalar multiplication, or applying math functions, preserve the index-value link -- 

`obj2[obj2>0]` `np.exp(obj2)`

Another way to think about a Series is as a fixed-length, ordered dictionary -- as it is mapping of index values to data values-- cna be used in many contexts where you might use a dictionary. Just like:

```py
sdata=dict(Ohio=35000, Texas=71000, Oregon=16000, Utah=5000)
obj3 = pd.Series(sdata)
```

A series can be converted back to a dictionary with `to_dict()`. When you are only passing a dictionary, the index in the resulting Series will respect the order of the keys according to the dictioanry's `keys`method, which depends on the key insertion order. can override this by passing an index with the dictionary keys in the order you want them to appear in resulting Series.

```py
states= ['California', 'Ohio', 'Oregon', 'Texas']
obj4 = pd.Series(sdata, index=states)
```

Here, three values found in `sdata`were placed in the appropriate locations -- but one not found, appears `NaN`. Which is considered in pandas to mark missing or NA values. The `isna`and `notna`functions in pandas should be used to detect missing data. like:

`pd.isna(obj4); pd.notna(obj4), obj4.isna()`

Need to note that both the Sereis object self and its index have a `name`attribute, which integrates with other areas of pandas functionality like:

`obj4.name='population'`, `obj4.index.name='state'`

And a series' index can be altered in place by assignment.

### DataFrame

Represent a rectangle table of table and contains an ordered, named collection of columns -- each of which can be a different value type, -- And has both a row and a column index, can be thought of as a dictionary of Series all sharing the same index. There are many ways to construct a DataFrame, though one of the most common is from a dictionary of equal-length lists or Numpy arrays like:

```py
data = {'state': ['Ohio', 'Ohio', 'Ohio', 'Nevada', 'Nevada', 'Nevada'],
        'year': [2000, 2001, 2002, 2001, 2002, 2003],
        'pop': [1.5, 1.7, 3.6, 2.4, 2.9, 3.2]}
frame = pd.DataFrame(data)
frame
```

For larger DataFrames, the `head`method selects only 5. `tail`returns the last 5. need to note if specify a seq of columns, the DataFrame's columns will be arranged in that order like:

`pd.DataFrame(data, columns=['year', 'state', 'pop'])`

And if pass a column that isn't contained in the dict, it will appear with missing values in the result. like:

```py
frame2 = pd.DataFrame(data, columns=['year', 'state', 'pop', 'debt'])
frame2.columns
```

So, a column in DataFrame is jsut can be retrieved as a Series either by dict-like notation or by using the dot attribute notation like: And note: Attribute-like access and tab completion of clumns in IPython are -- `frame2[column]`works for any column name, but `frame2.column`works only when the column name is valid Py vairable name and does not conflict with any of the method names in DataFrame.

Just note that the returned sereis have jsut the same index as a `DataFrame`.

Rows can also be retrieved by position or name with the specal `iloc`and `loc`attriute fore:

`frame2.loc[1], fram2.iloc[2], frame2['debt']=16.5`

`frame2['debt']=np.arange(6.)`

Whenare assigning lists to a column, the value's length **must** match the length of the DataFrame. And if assign a Sereis, its label will be realigned exactly to the DF's index, inserting values in any index value are not present.

```py
val = pd.Series([-1.2, -1.5, -.17], index=['two', 'four', 'five'])
frame2['debt'] = val
frame2  # NaN for all
```

And the `del`keyword will delete columns like with a dictionary, as an example, first add a new column of Boolean values where the `state`column equals `Ohio`.

`frame2['eastern']=frame2['state']=='Ohio'`

And the `del`method can then be used to remove this column like: `del frame2['eastern']`

The column returned from indexing a DataFrame is a *view* on the underlying data, not a copy -- Thus, any in-place modifcations to the `Series`will be just reflected in the DF. the column can be explicitly copied with the `Series'`copy method.

And, another comon form of data is nested dictionary of dictionaries like:

```py
population = {'Ohio': {2000: 1.5, 2001: 1.7, 2003: 3.6},
              'Nevada': {2001: 2.4, 2002: 2.9}}
pd.DataFrame(population) # inner dict keys as indcies
```

If the nested dict is passed to the DF, pandas will intercept the outer dict keys as columns, and inner as row indices.

`frame3.T` -- And note that transposing discards the column data types if the columns do not have the same data type. So transposing and then transposing back may lose the previous type info. And the keys in the inner dictionaries are combined to form the index in the result, this isn't true if an explicit index is specified like: For a list of many of the things you can pass to the DF ctor like:

- 2D ndarray
- Dictionaries of arrys, lists, or tuples
- Numpy structured/record array
- Dictionary of Series
- Dictioanry of Dicts
- Another DF

And, if a DF's `index`and `columns`has their `name`attributes set -- these will also be displayed like:

`frame3.index.name='year'`

```py
frame3.index.name='year'
frame3.columns.name='state'
```

Unlike Series, DF does not have a `name`attribute -- DF's `to_numpy`method returns a data contained in the DF as a 2d ndarray like: `frame3.to_numpy()`

## Concurrent web requests

Async context managers are classes that implement two special coroutine methods -- `__aenter__`which asnchoronusly acquires a resource and `__aexit__`which closes that resource, the `__aexit__`continue takes several arguments that deal with any exceptions that occur, which won't review in this chapter.

To full understand async managers, implement a simple one using lke:

```py
import asyncio
import aiohttp
from aiohttp import ClientSession
from util import async_timed
import nest_asyncio
nest_asyncio.apply()


@async_timed()
async def fetch_status(session: ClientSession, url: str) -> int:
    async with session.get(url) as result:
        return result.status


@async_timed()
async def main():
    async with aiohttp.ClientSession() as session:
        url = 'https://www.baidu.com'
        status = await fetch_status(session, url)
        print(f'Status for {url} was {status}')
        

asyncio.run(main())
```

And when run this, should see that 200 -- first creted a client session in the `async with`block with the `aiohttp.ClientSession()`-- once have a client session in an `async with`, request -- define a convenience method `fetch_status_code`method will take in a session and a RUL and return the status code for the given URL. In this function, have another `async with`block and use the session to run a `GET HTTP`request against the URL. This will give a result, which can then process within the `with`block.

And the `ClientSession`will create a default maximum of 100 connections by default, providing an implicit upper limit to the number of concurent requests we can make, and to change this limit, can create an instance of an aiohttp `TCPConnector`specifying the maximum number of connections and passing that to the `ClientSession`.

### Setting Timeouts with aiohttp

Can specify a timeout for an awaitable by using `asyncio.wait_for`-- this will also wrok for setting timeouts for an aiohttp request, but a cleaner way to set timeouts is to use the functionaliy that aiohttp provides out of the box. And by default, aiohttp has a timeout of 5 minutes, which means that no single ..  We can specify a timeout at either the session level, which will apply that timeout for every operation.

Can just sepcify timeouts using the aiohttp-specific `ClientTimeout`data structure, this not only allows us to specify a total timeout in seconds for an entire request but also allows us to set timeouts on establishing a connection or reding data. like:

```py
async def fetch_status(session: ClientSession, url: str) -> int:
    ten_mills = aiohttp.ClientTimeout(total=.01)
    async with session.get(url, timeout=ten_mills) as result:
        return result.status


async def main():
    session_timeout = aiohttp.ClientTimeout(total=1, connect=.1)
    async with aiohttp.ClientSession(timeout=session_timeout) as session:
        await fetch_status(session, 'http://www.baidu.com')


asyncio.run(main())
```

The first timeout is at the client-session level -- set a total of 1, and of 100 ms. in the `fetch_status()`we override this for our `get`request to set a total of 10ms -- in this , if request takes more than 10ms, `asyncio.TimeoutError`will be raised when we `await`. 

### Running tasks concurrently

Used `acyncio.create_task`and then awaited the task as -- 

```py
import asyncio
async def main() -> None:
    task_one = asyncio.create_task(delay(1))
    task_two = asyncio.create_task(delay(2))
    await task_one; await task_two
```

This works for simple cases like the previous in which have one or two coroutiens want to launch concurrently.

```py
@async_timed()
async def main() -> None:
    delay_times = [3,3,3]
    [await asyncio.create_task(delay(seconds)) for seconds in delay_times]
```

However, in this case 9 seconds elapsed to run. Since everything is just done sequentially.

It occurs cuz just use `await`as soon as we create the task -- this means that we just pause the list comprehension and the main coroutine for every `delay`task we create until the `delay`task completes. And in this case, will have only one task runinng at any given time -- instead of running multiple tasks concurrently - fix is esy -- create a tasks in one listcomp and `await`in a second like:

```py
from util import async_timed, delay

@async_timed()
async def main():
    delay_times=[3]*3
    tasks = [asyncio.create_task(delay(seconds)) for seconds in delay_times]
    [await task for task in tasks]
    
asyncio.run(main())
```

This code just creates a number of tasks all at once in the tasks list -- once we have created all the tasks, we await their completion in a separate comp. -- This works cuz `create_task`method returns instantly -- don't do anything awaiting until all the tasks have been created. This ensures that it only requires at most the maximum pause in `delay_times`.

But, drawbacks remain -- the first is that this consists of multiple lines of code, where must explicitly remebmer to separte out our task creation from our awaits. The second is that the inflexible. And if one of that just finishes long before the others-- we will be trapped in the second acceptable in certain circumstances. Want to be more responsive, processing our results as soon as they arrive. The third, and potentially biggest issue, is exception handling, and if one of has an expcetion, will be thrown when we `await`the failed task.

asyncio has convenience functions to deal with all these situations and more.

### Running requests concurrently with `gather`

A widely used async API functions for running awaitable concurrently is `asyncio.gather`-- this takes in a sequence of awaitables and lets us run them concurrently - all in one line of code -- if any of the awaitables we pass in is a coroutine, `gather`will **automatically** wrap it in a task to ensure that it runs concurrently. means that don't have to wrap everything with `asyncio.create_task`separately.

It returns an awaitable, when use it in an `await`expression, will pause until awaitables that we passed into it are complete -- once everything we passed in finishes, `asyncio.gather`will return a list of the *completed* results.

```py
from util import fetch_status


@async_timed()
async def main():
    async with aiohttp.ClientSession() as session:
        urls = ['http://www.baidu.com' for _ in range(1000)]
        requests = [fetch_status(session, url) for url in urls]
        status_codes = await asyncio.gather(*requests)
        print(status_codes)


asyncio.run(main())
```

First, generate a list of URLs we'd like to retrieve the status code from -- for simplicity, request that repeatedly. This just indicates that requests occur after another -- waiting for each call to `fetch_status`to finish before moving to the next request - It is worth nothing that the resutls for each awaitable we pass in may not complete in a deterministic order. fore:

`results = await asyncio.gather(delay(3), delay(1))`

[3, 1] returned -- the order we apssed things in -- the `gather`just keeps result ordering deterministic despite the inherent nondeterminism behind the scenes. In the background, `gather` uses a special kind of `future`implementation to do this. 

### Handling Exceptions with `gather`

When make a web requets, might not always get a value back - we might get an exception -- since networks can be unreliable, different failure cases are possible. -- fore, could pass in an address that is invalid or has become invalid cuz the site has been taken down.

`asyncio.gather`just gives us an optional parameter -- `return_exceptions`, which allows us to specify how we want to deal with exceptions from our awaitables, -- `return_exceptions`is a boolan value like:

- `False`-- default -- in thiscase, if any of the coroutine throws an exception, `gather`call will also throw when `await`that, -- however, even though one of our coroutines failed, our other coroutines are not canceled and will continue to run as long as handle the exception, or the exception does not result in the loop stopping and cancelling this task
- `True`-- will return any expceitons as part of the result list it returns when we `await`it. The call to `gather`will not throw any expceiotns itself.

Fore, jsut contain an invalid addrss -- like:

```py
async def main():
    async with aiohttp.ClientSession() as session:
        urls = ['http://baidu.com', 'python://wrong.com']
        tasks = [fetch_status(session, url) for url in urls]
        status_code= await asyncio.gather(*tasks, return_exceptions=True)
        print(status_code)
        
asyncio.run(main())
```

`asyncio.gather`won't cancel any other tasks that are running if there is a failure. That may be acceptable for many use cases but is one of the drawbacks of `gather`. Can fix that by using `return_exceptions=True`which will return all exceptions we encounter when running our coroutines -- can then fitler out any exceptions and handle them as needed.

```py
async def main():
    async with aiohttp.ClientSession() as session:
        urls = ['http://www.baidu.com', 'python://wrong.com']
        tasks = [fetch_status(session, url) for url in urls]
        results = await asyncio.gather(*tasks, return_exceptions=True)
        exceptions= [res for res in results if isinstance(res, Exception)]
        successful_results= [res for res in results if not isinstance(res, Exception)]
        print(f'All results: {results}')
        print(f'Finished Successfully: {successful_results}')
        print(f'Threw exceptions: {exceptions}')
        
asyncio.run(main())
```

This solves this issue of not being able to see all the exceptions that our coroutines throw. It is also nice that now we dont need to explicitly handle any exceptions with a `try`and `catch`block, since we no longer throw an exception when we `await`.

`gather`has a few drawbacks -- which was already -- isn't easy to cancel our tsks if one throws an exception. Imagine a case in which we are making requets to the same server, and if one request fails, all other will as well.

Second is that must wait for all to finish before we can process our results -- if want to deal with results as soon as they just complete, this poses a problem.

## Administration

Creating the Module -- The process of creating the feature module follows the same pattern you have seen in eariler chapters -- the key difference is that it is important that no other part of the application has dependencies on the module or the classes it contains.

The starting point for the administration features will be authentication -- which will ensure that only authorized users can adminster the app, create `auth.component.ts`file in the `admin`folder, and used it to define the component like:

```tsx
@Component({
    templateUrl: "auth.component.html"
})export class AuthComponent {
    username?:string;
    password?:string;
    errorMessage?:string;

    constructor(private router: Router) {
    }
    
    authenticate(form: NgForm) {
        if(form.valid) {
            // perform some auth
            this.router.navigateByUrl("/admin/main")
        }else {
            this.errorMessage="Form data Invalid";
        }
    }

}

```

The component defines properties for the username and password that will be used to authenticate the user, an `errormessage`property that will be used to display messags when there are problems. And an an `authenticate`method will perform the anthentication process.

```html
<div class="bg-info p-2 text-center text-white">
    <h3>SportsStore Admin</h3>
</div>

<div class="bg-danger mt-2 p-2 text-center text-white"
     *ngIf="errorMessage!=null">
    {{errorMessage}}
</div>

<div class="p-2">
    <form novalidate #form="ngForm" (ngSubmit)="authenticate(form)" >
        <div class="mb-3">
            <label>Name</label>
            <input class="form-control" name="username"
                   [(ngModel)]="username" required />
        </div>
        
        <div class="mb-3">
            <label>Password</label>
            <input class="form-control" type="password" name="password"
                   [(ngModel)]="password" required />
        </div>\
        
        <div class="text-center p-2">
            <button class="btn btn-secondary m-1" routerLink="/">go back</button>
            <button class="btn btn-primary m-1" type="submit">Log in</button>
        </div>
    </form>
</div>
```

The template contains an HTML form uses two-ways data-binding expressins for the component’s properties. And to create a placehilder for the administration features, added a file called `admin.component.ts`int the admin folder like:

```tsx
@Component({
    templateUrl: "admin.component.html"
})export class AdminComponent {}
```

For this, doesn’t contain any functionality at the moment, just provide a template for that:

```ts
let routing = RouterModule.forChild([
    {path: 'auth', component: AuthComponent},
    {path: 'main', component: AdminComponent},
    {path: '**', redirectTo: 'auth'}
]);

@NgModule({
    imports: [CommonModule, FormsModule, routing],
    declarations: [AuthComponent, AdminComponent],
})
export class AdminModule {
}
```

The `RouterModule.forChild()`is used to define the routing configuration for the feature module, which is then included in the module’s `imports`property.

And a dynamically load module must be self-contained and include all the information that Ng requires. Including the routing URLs that are supported and the components they displays. And if any other part of the app depends on the module, then it will be included in the Js boundle with the rest of the application code, which means that all users have to download code and resources for features they won’t use.

### Configuring the URL routing system

Dynamically loaded modules are managed through routing configuration, which triggers the loading process when the app navigates to a specific URL.

```tsx
{
    path: 'admin', loadChildren: () => import('./admin/admin.module')
        .then(m => m.AdminModule),
        canActivate: [StoreFirstGuard]
},
```

The new route tells Ng that when the application navigates to the `/admin`url, should just load a feature module defined by a class called `AdminMoudle`from the `/admin.module.ts`file -- whose path is specified relateive to the app.module.ts file.

### Navigating to the Administration URL

The final preparatory step is to provide the user with the ability to navigate to the `/admin` -- just add in the `store.component.html`file like:

```html
<button class="btn btn-danger mt-5" routerLink="/admin">
    Admin
</button>
```

### Implementing Authentication

The RESTful web services has been configured that it requires authentiation for the requests that the administration feature will require -- In the-- add just support for authenticating the user by sending an HTTP.

When the RESTful web service authenticates a user, it just return a JWT (JSON web token) that the app must include in subsequent HTTP requests to show the authentication that has been successfully performed. But for the app, it is just enough to know that the Ng can authenticate the user by sending a POST to the `/login`URL, including a JSON-formatted object in the request body that contains name and password properties -- there is only one set of valid credentials in the authentiation code.

If the correct credentials are sent to the `/login`url, then the response from the RESTful web service will contain a JSON object like:

```json
{
    "success": true,
    "token": ...
}
```

The `success`prop describes the outcome of the authentication operation, and the `token`prop contains the JWT, which should be included in subsequent requests using the `Authorization`http header. And configured the JWT tokens returned by the server so they expires after one hour.

### Extending the data source

The RESTful data source will do most of the work cuz it is just responsible for sending the authentiation rquest to the `/login`URL and including the JWT in the subsequent requests.

```ts
authenticate(user: string, pass: string): Observable<boolean> {
    return this.http.post<any>(this.baseUrl + "login", {
    name: user, password: pass
}).pipe(map(response => {
    this.auth_token = response.success ? response.token : null;
    return response.success;
}))
}
```

`pipe`and `map`are provided by the Rxjs package. and they allow the response event from the server, which is presented through an `Observable<any>`to be transformed into an event in the `Observable<bool>`

### Creating the Authentication Service

Rather than expose the data source directly to the rest of the appliation, going to create a service that can be used to perform authentiation and determine whether the app has been authenticated. In the `model`folder add:

```ts
@Injectable()
export class AuthService {
    constructor(private dataSource: RestDatasource) {
    }

    authenticate(username: string, password: string): Observable<boolean> {
        return this.dataSource.authenticate(username, password);
    }

    get authenticated(): boolean {
        return this.dataSource.auth_token != null;
    }

    clear() {
        this.dataSource.auth_token = undefined;
    }
}
```

The `authenticate`method receives the user’s credentials and passes them on the data source `authentiate()`, returning an `Observable`that will yield `true`if the authentication process has succeeded and `fasle`otherwise. The `authenticated`prop is a getter-only prop that returns `true`if the data source has obtained an authentication token. 

Then just registers the new service with the model feature module, It also adds a `providers`entry for the `RestDataSource`class, which has been used only as a substitute for the `StaticDataSource`class.

### Enabling the Authentication

The next is to just wire up the component that obtains the credientials from the user so that it will perform authentiation through the new service like:

```ts
authenticate(form: NgForm) {
    if(form.valid) {
        // perform some auth
        this.auth.authenticate(this.username ?? "", 
                               this.password??"")
                               .subscribe(resp=> {
                               if(resp) {
                               this.router.navigateByUrl("/admin/main");
    }
    this.errorMessage="Authentication Failed";
})
}else {
    this.errorMessage="Form data Invalid";
}
}
```

And to prevent the appliation from navigating directly to the administration features, which will lead to HTTP requests being sent without a token, need to add `auth.guard.ts`file in the `admin`folder and defined the route like:

```tsx
@Injectable()
export class AuthGuard {
    constructor(private router: Router, private auth: AuthService) {
    }

    canActivate(route: ActivatedRouteSnapshot, state: RouterStateSnapshot): boolean {
        if (!this.auth.authenticated) {
            this.router.navigateByUrl("/admin/auth");
            return false;
        }
        return true;
    }
}
```

To test the authentication system, just hard-coded in the JSON file, user is `admin`and password is `secret`.