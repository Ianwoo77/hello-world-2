# How to Use Nginx as a Load Balancer

Thanks to the reverse proxy design of Nginx, you can easily configure it as a load balancer. Load balancing may be required on large scale projects distributed across multiple servers. For this simple demo, created 3 very simple Node.js responding with a server number and 200 status code.

```sh
pm2 start server-1.js
pm2 start server-2.js
# ...
```

For this, Three Node.js servers should be running on 3001, 3002, and 3003, then update configuraiton as:

```nginx
events {}
http {
    upstream backend_servers {
        server localhost:3001;
        server localhost:3002;
        server localhost:3003;
    }
    
    server {
        listen 80;
        server_name nginx_handbook.tests;
        location / {
            proxy_pass http://backend_servers
        }
    }
}
```

The configuration inside the server context is the same as you have already seen. The `upstream`context, though, is new, An upstream in Nginx is a collection of servers that *can be treated as a single backend. So the three servers you started using PM2 can be put inside a single upstream and can let Nginx balance to load between them.

Can stop the 3 running server by executing `pm2 stop server-1 server-2 server-3`command

### How to optimize Nginx for maximum performance

In this of the article, learn about a number of ways to get the maximum performance from your server. Some of these methods will be just application-speicifc, which just means that they will probably need tweaking considering your application requirements. But some of them will be generally optimization techniques.

How to configure worker Processes and worker connections -- For this, Nginx can spawn multiple worker processes capable of handling thousands of requests each. 

```sh
sudo systemctl status iginx
```

Can see, right now there is only one Nginx worker proces on the system. This number, however, can be changed by making a small change to the configuration file.

```nginx
worker_processes 2;

events {
}

http {

	server {
		listen 80;
		server_name nginx-tests;

		return 200 "worker processes and worker connections configuration\n";
	}
}
```

And the `worker_process`directive written in the `main`context is responsible for setting the number of worker processes to spawn. Then check the NGINX service once again, should see two worker processes.

For this, setting the number of worker processes is just easy, but determining the optimial number of worker processes requires a bit more work. The worker processes are async in nature - this means that they will process incoming requests as fast as the hardware can.

Consider that your server runs on a single core processor - if set the number of worker processes to 1 -- the single process will utilize 100% of the CPU capacity, but for now, if set it to 2, the two processes will be able to utilize 50% of the CPU each. so, increasing the number of worker processs doesn’t mean better performance.

A rule of thumbe in determining the optimal number of worker processes is **number of worker process=number of CPU cores**

So, if are running on a server with a dual core CPU, the number of worker processes should be set to 2, in a quad core it should be set to 4.. and get the idea. For linux, just `nproc`-- now that you just know the number of CPUs, all that is left is to do is set the number of the configuration.

NGINX provides a better way to deal with this issue, Can simply set the number of worker processes to `auto`and Nginx will just set the number of processes based on the number of CPUs automatically.

```nginx
worker_processes auto;
```

And Apart from the worker processes there is also th worker connection, indicating the highest number of connections a single worker process can handle.

And, just like the number of worker processes, this number is also related to the number of your CPU core and the number of files your operating system is allowed to open per core.

```sh
ulimit -n # return the CPU number of files your os is allowed to open per core, 1024 generally
```

Now that have the number can:

```nginx
worker_processes auto;
events {
    worker_connections 1024;
}
```

And the `worder_connections`directive is responsible for setting the number of worker connections in configuration. In a previous, mentioned that the context is used for setting values used by Nginx on a general level, the worker connections configuration is one such example.

### How to cache static content

And the second technique for optmizing your server is caching static content. Regardless of the app you are serving, there is always a certain amount of static content being served, such as stylesheets, images and so on. 

Need to consider that this content is not likely to change very frequently, it’s a good idea to cache them for a certain amount of the time.

```nginx
http {

	include /env/nginx/mime.types;

	server {
		listen 80;
		server_name nginx-tests;

		root /srv/nginx-handbook-demo/static-demo;

		location ~* \.(css|js|jpg)$ {
			access_log off;

			add_header Cache-Control public;
			add_header Pragma public;
			add_header Vary Accept-Encoding;
			expires 1M;
		}
	}
}
```

By writing `location ~* \.(css|js|jpg)$`-- you are just instructing Nginx to match requests asking for a file ending with `.css, js, jpg`, Usually, store images in the `WebP`format even if the user submits a different format. Can just use the `add_header`direceive to include a header in the response to the client.

Using the `proxy_set_header`directive used for setting headers on ongoing request to the backend server. The add_header directive on the other hand only adds a given header to the response.

- `Cache-Control`-- telling the client that this content can be cached in any way.
- `Pragma`-- older version of the `Cache-Control`
- `Vary`-- responsible for letting the client know that this cached content may vary.
- `Accept-Encoding`-- means that the content may vary depending on the content encoding accepted by the client.

Note that the **`expires`**-- allows U to set the `Expires`header conveniently. The `expires`directive takes a duration of time this cache will be valid. By setting it to `1M`, you are telling Nginx to cache the content for one month. U can also set this to 10m or 10 minutes, 24h...

As can see, the headers have been added to the repsonse and any modern browser should be able to interpret them.

## Tests Capture intent

Tests are not jsut about verifying that the system works, cuz we chould do that by hand, the deeper ponit about tests is that they capture *intent* -- they document what was in our minds when we built the software. As writing the tests, they serve to help us clarify and organise our thoughts about what we actually want the system to do -- cuz if don’t know that, how on earth can we expected to code it.

Start by describing the required behavirour in words -- The most important single aspect of software development is to be clear about what we are trying to build.

Test names should be sentences -- So now have a really clear idea about the behaviour we want, the next step is to communicate that idea to someone else -- the test as a whole should serve this purpose, let’s start with the test *name*. Know that test functions in Go need to start with the word `Test`-- but the rest of the function name is up to us.

### Failures are a message to the future

There doesn’t seem to be *too* much wrong with this -- and indeed there isn’t , it’s a perfectly reasonable test. But it doesn’t communicate as much as it could. When it fails, what we see --  It leaves the reader with many question -- 

- waht value were we inspecting -- 
- why did we expect it to be true
- for what input
- what does it mean that we got `false`instead -- 
- in what respect is the system not behaving as specified.

The power of combining tests -- Ignoring errors is a mistake -- It’s common for Go functions to return an error value as part of their results -- it’s especially common for functions to return sth and error like this -- 

`func CreateUser(u User) (UserID, error) {...}`

So, how test a function like this -- look at a few of wong ways to do it first -- like:

```go
func TestCreateUser(t *testing.T) {
    want := 1
    got, _ := CreateUser("some valid user")
    if want != got {
        t.Errorf("...")
    }
}
```

Here, if there were some bugs that caused `CreateUser`to return an error when it shouldn’t

`DB.Exec()`-- this provides two methods -- 

- `LastInsertId()`-- which returns the integer generated by the dbs in response to a command -- Typically this will be from an auto increment column when inserting a new row, which is exactly what’s happening in our case.
- `RowsAffected()`-- which returns the number of rows affected by the statement.

Important -- Not all drivers and dbs support the `LastInsertId()`and `RowsAffected()`methods -- fore, the `LastInserteId()`is not supported by the `PostgreSQL`-- so planning our using these methods it’s important to check the documenation for your particular driver first.

### Using the model in our handlers

Bring this back to sth more concrete and demonstrate how to call this new ccode from our handlers -- like:

```go
// change the signature like:
func (app *application) createSnippet(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		w.Header().Set("Allow", http.MethodPost)
		app.clientError(w, http.StatusMethodNotAllowed)
	}

	// create some variables holding dummy, remove this later
	title := "0 snail"
	content := "0 snail\nClimb Mount Fuji,\nBut slowly, slowly!\n\n - Koayashi Issa"
	expires := "7"

	// pass the data to the Insert() method receiving the ID of the new record back
	id, err := app.snippets.Insert(title, content, expires)
	if err != nil {
		app.serverError(w, err)
		return
	}

	http.Redirect(w, r, fmt.Sprintf("/snippet?id=%d", id), http.StatusSeeOther)
}
```

```sh
curl -iL -X POST http://localhost:4000/snippet/create
```

just sent a HTTP request which triggered our `createSnippet`handler -- which in turn called `Insert()`method. Fore this, we’ve just sent a HTTP request which triggered our `createSnippet`handler, which in trun called our `SnippetModel.Insert()`method, this inserted a new record in the dbs and returned the ID of this new record, our handler then issued a redirect to another URL with the ID as a query string parameter.