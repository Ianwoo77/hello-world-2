# Location Matches

The first concept we will discuss in this section is the `locaiton`context. Update the configuration as follows: And for the `/srv`directory is meant to contain site-specific data which is served by this system. Update as:

```nginx
http {
	server {
		listen 80;
		server_name nginx-tests;
		
		root /srv/nginx-handbook-projects/static-demo;
	}
}
```

This code is almost the same, except the `return`directive has now been replaced by a `root`- is used for declaring the root directory for a site. By writing this, you are telling nginx to look for files to serve inside the specified directory if any request comes to this server. Since Nginx is just a web server, it is smart enough to serve `index.html`by default. 

But for now, the CSS code is not working. So:

### Static file types handling in Nginx

```sh
curl -I http://localhost/mini.min.css
```

Just pay attention to the `Content-Type`and see how it says `text/plain`and note the `text/css`, and this means that Nginx is serving this file as plain text instead of a stylesheet.

Alough Nginx is smart enough for find the `index.html`file by default, it’s pretty dumb when it comes to interpreting the file types -- to solve this problem update like:

```nginx
types {
    text/html html;
    text/css css;
}
```

For this, the only changes we’ve made to the code is new `types`context nested inside the `http`block -- as may have already guessed from the name, this context is used for configuring file types., for this, by writing `text/html html`in the contxt jsut telling Nginx to parse any fiel with `.html`extension.

Note -- if just introduce a `types`context in the configuration, Nginx becomes even dumber and only parses the file configured by U. So if you only define the `text/css css`in this confext when Nginx will start parsing the HTML file as plain.

### How to include Partial config files -- 

Mapping file types within the `types`context may work for small projects, but for bigger projects it can be cumbersome and error-prone. And NGINX just provides a solution for this problem, if you list the files insdie the `/etc/nginx`directory once again, will see a file named `mime.types`-- the file contains a long list of file types and their extensions -- to use this file inside your configuration file, update your configuration to look as like:

```nginx
include /etc/nginx/mime.types;
```

The old `types`context has now been replaced with a new `include`directive -- like the name suggests, this directive allows you include content from other configuration files.

### Dynamic Routing in Nginx

And the configuration you wrote -- very simple static content server configuration -- all it did was match a file from the site root corresponding to the URI the client visits and respond back.

In this section, learn about the `location`context, variables, redirects, rewrite the `try_files`directive, there will be no new projects -- but the concepts you learn here will be necessary in the upcoming sections. Also the configuration will change very frequetnly in this section, so do not forget to validate and reload the configuration after every update.

location matches -- 

```nginx
server {
    listen 80;
    server_name nginx-tests;

    location /agatha {
        return 200 "Miss Marple.\nHercule Prirot.\n";
    }
}
```

Just replaced the `root`directive with a new `location`context -- this is usually nested insdie `server`blocks. There can be mutliple `location`contexts within a `server`context.

```nginx
location = /agatha {
    return 200 "Miss Marple.\nHercule Prirot.\n";
}
```

To perform an *exact match* -- have to update like previous. Adding an `=`sign before the location URI will instruct NGINX to respond only if the RUL matches extactly.

Another kind of match in Nginx is the **regex match** -- using this match you can check the location URLs against complex regular expressions -- like:

```nginx
location ~ /agatha[0-9] {
    return 200 "Miss Marple.\nHercule Prirot.\n";
}
```

So, by replacing the prevously, used `=`with a `~`sign, you are telling Nginx to peform a regular expression match. Setting the location to `~ /agatha[0-9]`means Nginx will only respond if there is a number after the word. And a regex match is by default case sensitive, which means that if you capitalize any of the letters like: To turn this into case insensitive, have to add a `*`after the `~`sign like: `        location ~* /agatha[0-9] {...}`

That will tell Nginx let go of types sensitivity and match the location anyways. Nginx assigns priority values to these matches -- and a regex match has more priority than a prefix match like:

```nginx
location Agatha8 {
    return 200 "prefix matchesd.\n";
}

location ~* /agatha[0-9] {
    return 200 "regex matched\n";
}
```

And this priority can be changed a little -- the final step of match in Nginx is a *preferential preix match* -- to turn a prefix match into a preferential one, need to include the `^~`modifier before the location URI -- like:

```nginx
location ^~ Agatha8 {
    return 200 "prefix matchesd.\n";
}
```

| Match               | Modifier    |
| ------------------- | ----------- |
| Exact               | `=`         |
| preferential Prefix | `^~`        |
| REGEX               | `~` or` ~*` |
| Prefex              | None        |

### Variables in Nginx

Variables in Nginx are similar to variables in other programming languages. The `set`directive can be used to declare new variables anywhere within the configuration file like:
`set $<variable_name> <vairable_name>;`

And note that variables in Nginx can be of 3 types -- `String Integer boolean`

Note- apart from the variables U declare, there are embedded variables within Nginx modules -- an alphabetical index of variables is available in the official documentation. As can see, the `$host`and `uri`variables hold the root address and the requested URI relative to the root, respectively. The `$args`-- contains all the query strings.

The variables I demonstrated here are embedded in the -- for a variable to be accesible in the configuration, Nginx has to be built with the module embedding the variable Building Nginx from source and usage of dynamic modules is slightly out of scope for this.

```nginx
server {
    listen 80;
    server_name nginx-tests;

    set $name $arg_name;
    return 200 "Name: $name\n";
}
```

The variables demonstrated where are embedded in the `ngx_http_core_module`-- For a variable to be accessible in the configuration, Nginx has to be built with the module embedding the variable.

## Tools for testing

In every mainstream programming lang, there are dozens of softare packages intended for test configuration. Go’s approach to testing can seem rather low-tech in comparison -- it just relies on one command `go test`, and a set of conventions for writing test functions that go test run run -- the comparatively lightweights mechanism is effective for pure tesintg, and it extends naturally to benchmarks and systematic examples for documentation.

### Go’s built-in tesing facilities

To streamline this process, though, the Go stdlib provides a package named `testing`that can import an use in test code. The facility to build, run, and report test results is also built into the Go tool itself. Go looks for test code in files whose name end with `_test.go`, no other files will be considered when runing tests, so `_test`in the name.\

Note that it’s not mandatory, to put source files containing test code in the same folder as the package they are testing, fore, suppose we have some file .. And one nice thing about using the `testing`package, as opposed to rolling our down, is that test code is ingored when build the system for release.

For this, we could use package `service`, and that would work, let’s use the `service_test`instead, to make it clear that this is *test* code, not part of the system itself.

Writing and running tests -- When eventually come to run this, Go will start by looking for all files ending in `_test`and inspecting them to see if contains tests. like:

```go
func TestAlwaysPass(t *testing.T) {
	// all good
}
```

If try to: `func TestAlwaysPasses(){}`-- wrong signature for `TestAlawaysPasses`

```go
func TestAlwaysPass(t *testing.T) {
	t.Error("no no")
}
```

Interpreting test output -- `FAIL`message telling us that some test has failed, saw the `name`for the test that filed, and how look to fail. A test that always fails is not much more use than one that always passes. And that condition depends on what behaviour we’re testing, of course, let’s say the behavior we’re interested in that we can detect that the service is running, we might suppose some `Running`function, fore, which returns `true`when the service is running.

```go
func TestRunningIsTrueWhenServiceIsRunning(t *testing.T) {
	t.Parallel()
	service.Start()
	if !service.Running() {
		t.Error(false)
	}
}
```

Since, havn’t implemented the code for the `Start`or `Running`yet, feel instinctively that this test should fail.

```go
func Running() bool {
	return false
}

func Start(){}
```

Validating our mental models -- We are essentially building a mental model of the solution, and developing that model inside the computer at the same time.

### Concurrent tests with `.Parallel`

Go is justly praised for its first-class concurrency support, and the `testing`package is no expceiton. By calling `t.Parallel()`any tests can declare itself suitable to run concurrently with other tests like:

```go
func TestCouldTakeAWhile(t *testing.T) {
    t.Parallel()
    // this could take a while
}
```

For this, if have more than 1 CPU, which is likely, then you can speed up your tests by runing them in parallel like this.

Failures `t.Error`and `t.Errorf`-- If writing really short, focused tests, with well-chosen nams, then don’t need to say much more in the failure message, could discuss this again in more detail in the.. For now, say simply that a good test *name* is a sentence describing the expected behaviour -- like:

Sometimes there are just other possible outcomes, and it may be useful to know which one we are seeing, fore, since many Go functions return `error`along with some data value, it’s as important to test that `error`results as any other. like:

```go
if err != nil {
    t.Error(err)
}
```

Conventinetly, can just pass any tpe of value as the argument to `Error`-- and not just any type, but any *number* of values of any type. fore:

```go
want:=4
got:=Add(2,2)
if want != got {
    t.Error("want", want, "got", got)
}
```

And, if would have been *sufficient*, if not exact helpful, to jsut say sth like `failed`, or wrong answer, but this is a good deal better. just like:

```go
want := "hello"
got := Greeting()
if want!= got {
    t.Errorf("want: %q, got: %q", want, got)
}
```

Abandoning the test with `t.Fatal`-- It’s worth knowing that `t.Error`marks the test as failed, but doesn’t stop it. There may be more things to test, even though this one has failed, so the test will continue. In other situations, though, it might be better to bail out of the test as soon as something has failed, fore, suppose we need to set up some text fixure, such as a data file -- opening a file can always fail, need to check that error like:

```go
f, err := os.Open("testdata/input")
if err != nil {
    t.Fatal(err)
}
```

If can’t open the file, then there is no point continuing with the test -- attempting to read from `f`succeed, cuz it’s nil, in that case, whatever else we do in is test will be a waste of time at best, and fail confusing at worst. That is not cuz of a failure in the sysytem under test. It’s cuz we couldn’t construct our fixture correctly. In a situation like this, want to fail the test and stop immediately, which is what `t.Fatal()`does.

So, while `Error`and `Fatal`both ways of causing a test to fail, `Error`*fails and continues*, whereas `Fatal`fails and `bails`and if you are ever in doubt which one to use, -- ask yourself:

Is there any useful info to be gained by continuing with the test. If not, just `Fatal()`used.

writing debug output with `t.Log()`-- Speaking of useful info, somethings we’d like the test to be able to output things that aren’t failure messages.