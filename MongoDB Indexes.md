# git(rev)

```sh
git config --global user.name "<name>"
git config --global user.email "<email>"
git config --global --list
```

### Local repositories

A repository is how we refer to a project version controlled by Git. There are two types of repositories.

- A *local* repository is a repository that is stored on a computer.
- A *remote* repository is a repository that is hosted on a hosting service.

#### Initializing a Local Repository

A local is represented by a hidden dirctory called `.git`that exists within a project directory. And to initialize a Git repository, just use the `git init`command -- For the project, you will initialize the repository by using the `git init`command with the `-b`option and pass in the name `main`. Just like:

```sh
git init 	# Initialize a Git repository
git init -b main # with name main
```

#### The Areas of Git

There are four important areas to be aware of when you are working with Git like:

- Working directory
- Staging area
- Commit history
- Local Repostiory

To continue building the Git Diagram, will add a representation of the working directory to it. And the *staging area* is similar to a rough draft space. It is where U can add and remove files, when you are parparing what you want to include in the next saved version of your project. The staging area is represented by a file in the `.git`directory called `index`.

A *commit* is basically one version of a project. Think of it as a snapshot of a project, or a standalone version of a project that contains references to all the files that are part of that commit. *commit hash* -- unique 40-character hash composed of letters and numbers that acts like a name for a commit.

#### Commit History

Can think of your commits existing. It is represented by the objects directory inside the `.git`directory.  Adding a File to a Git project.

### Making a Commit

Now have a project directory called `rainbow`that has a `.git`directory inside it. A commit basically represents one version of a project. Two steps to make a commit -- 

1. Adding all files you want to incldue in the next commit to the staging area.
2. Make a commit with a commit messsage.

```sh
git add <filename>
git add <filename> <filename>...
git add -A # Add all the files in the working directory
```

The `rainbowcolors.txt`file is now in the working directory and in the staging area. Just like:

```sh
git commit -m "<message>"
git commit -m "red"
```

#### Viewing a list of commits

To see a list of commits in the commit history, use the `git log`command -- 

1. Commit hash
2. Author name and email address
3. Date and time commit was made
4. Commit message

### Branches

Focus on the commit history, going to introduce a new diagram called the *repository Diagram*. The Repository Diagram includes only a representation of the commit history of a repostiory and the revelant branches and referneces. Can think of a branch like a line of development -- A Git repository can have multiple branches -- each of these branches is a standalone vesion of the project. For this, in the Rainbow repostory, the `main`branch points to the red commit.

## Code And Project Organization

- Orgnaizing our code idiomatically
- Dealing effecitvely with abstractions: interfaces and generics
- Best practices regarding how to structure a project

### Unintended variable shadowing

Shows an unintended side effect cuz of a shadowed variable like:

```go
var client *http.Client
if tracing {
    client, err := createClientWithTracing()
    if err != nil {
        return err
    }
    log.Println(client)
}else {
    client, err := createDefaultClient()
    if err != nil {
        return err
    }
    log.Println(client)
}
// use client
```

Note that use the short variable declaration operator (:=) in both inner blocks to assigns the result of the function call to the inner `client`variable. How can we ensure that a value is assigned to the original `client`-- like just:

```go
var client *http.Client
if tracing {
    c, err := createClientWithTracing()
    if err != nil {
        return err
    }
    client = c
}else {
    // same logic
}
```

Assigned the result to a temporary variable, `c`-- scope is only within the `if`block. The second option uses the assignment operator in the innter blocks to directly assign the function results to the `client`variable.

```go
if tracing {
    client, err = createClientWithTracing()
}else {
    client, err = createDefaultClient()
}
if err != nil {
    // common error handling
}
```

