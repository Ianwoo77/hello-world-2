# Git pull from Github

When working as a team on a proj, it is important that every stays up to date. Any time you start working on a proj, you should get the most recent changes to your local copy. With Git, just can do that with `pull`. `pull`is a combination of 2 different commands - `fetch`and `merge`.

`fetch`gets all the change history of a trcked branch/repo like:

```sh
git fetch origin
git status

# cuz are behind the origin/master by 1 commit, should be updated
git log origin/master

# can verify the difference between local master and `origin/master`
git diff origin/master

# have confirmed updates are expected, can merge current branch with origin/master
get merge origin/master

# check status again to confirm
git status

# just want to update local repository, without going through all those steps -- 
# combination of fetch and merge
git pull origin
```

### Git push to GitHub

```sh
git commit -a -m "updated index.html, resized image"
git status
git push origin
```

Github branch -- Create a new branch on Github first, On github, acces your repository and click and fore:

Git Pull branch from GitHub -- Pulling a branch from github -- Now continue on new branch in local git -- lets pull from Github repository again so that our code up-to-date like:

```sh
git pull
```

Now new branch is up todate. And can see there is a new branch available on github just like:

```sh
git status
git branch # just master showed
```

So, don’t have the new branch on our local git, but we know it is avaiable on the Github, so just use the `-a` option to see all local and remote branches like:

```sh
git branch -a
git branch -r # only for remote branch
git checkout test1
git status
git pull
git branch # now on test1
```

## Beginning our Blog Project

```js
const express=requrie('express');
const app = express();
app.listen(4000, ()=> {console.log(...)})
```

### Automatic Server Restart with nodemon -- 

```sh
npm install nodemon --save-dev
```

The `--save`just is to have the dependencies listed in our package.json so that someone else can just install the dependencies later if we give them the proj -- they need only to run `npm install`with no arguments. Can also edit manually `package.json`and run to add depednencies. And the `-dev`just specify that we install `nodemon`for development purposes only.

npm start -- will be starting our app from within a `npm`script with `npm start`, to do so, in package.json, go to `scripts`and make the following change like:

```json
"script": {
    "start": "nodemon index.js"
}
```

So instead of running our app with `node index.js`we have done previously, we now run it with `npm start`, looks inside our `package.json`file, see that we have added a script called `start`. Cuz `npm start`is just s convention where most Node web servers can be started with `npm start`. Also, `npm start`allows you to run more complex commands when your app grows. Starting dbs server or clearing log files before starting up the server.

### public folder for serving static files

`app.use(express.static('public'));` with this, Express will expect all static assets to be in the `public`directory, thus, proceed to create a new folder called `public`in the app directory.

Creating Page routes -- Should serving thse files by defining specific routes with `app.get`and responding when specfic routes are hint as that done before.

```js
const express = require('express');
const path = require('path');
const app= new express();
app.use(express.static('public'));

app.get('/', (req, res)=> {
    res.sendFile(path.resolve(__dirname, 'pages/index.html'))
})
app.listen(4000, ()=> {
    console.log('App listening on port 4000');
})
```

Then just add some code likely --

```js
app.get('/about', (req, res)=>{
    res.sendFile(path.resolve(__dirname, 'pages/about.html'));
});

app.get('/concat', (req, res)=> {
    res.sendFile(path.resolve(__dirname, 'pages/contact.html'));
});

app.get('/post', (req, res)=> {
    res.sendFile(path.resolve(__dirname, 'pages/post.html'))
})
```

### Links in the index.html file

Now if you run the app and try to navigate to about, concat and sample post pages from the nav bar, you will realize that they don’t work or get a **cannot get /contact.html**

```html
<li class="nav-item">
	<a class="nav-link" href="index.html">Home</a>
</li>
<li class="nav-item">
	<a class="nav-link" href="about.html">About</a>
</li>
```

And cuz we have already moved them away sfrom the `public`folder, they can’t be found, instead like:

```html
<li class="nav-item">
	<a class="nav-link" href="/">Home</a>
</li>
```

### Unintended side effects with named result parameters -- 

Mentioned why named result parmeters can be useful in some situations -- but as these result parameters are initialized to their zero value, using them can sometimes lead to subtle bugs if we are not careful enough, illustrates such a case.

```go
func (l loc) getCoordinates(ctx context.Context, address string) (
    lat, lng float32, err error) {
    isValid := l.valiateAddress(address)
    if !isValid {
        return 0, 0, erros.New("invalid address")
    }
    if ctx.Err() != nil {
        
    }
}
```

