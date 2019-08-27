## Hi, Welcome to my nginx github page.

1. [What is nginx?](https://www.nginx.com/resources/glossary/nginx/)
2. Basics
  * [Directives](#directives)
  * [Array Directives](#array-directives)
  * [Standard Directives](#standard-directives)
  * [Action Directives](#action-directives)
  * [Context](#context)
  * [Variables](#variables)
  * [Http Directive](#http-directive)
  * [Server Directive](#server-directive)
  * [Location Directive](#location-directive)
  * [Logging](#logging)
  * [Return](#return)
  * [Rewrite](#rewrite)
  * [Try Files](#try-files)
  * [Worker Processes](#worker-processes)
  * [Worker Connections](#worker-connections)

> The way nginx and its modules work is determined in the configuration file. By default, the configuration file is named `nginx.conf` and placed in the directory `/usr/local/nginx/conf`, `/etc/nginx`, or `/usr/local/etc/nginx`.

### Directives

- A directive in nginx consists of a name and parameters separated by a space.
- A directive should always end with a semicolon(;).
- Directives in nginx are of 2 types
    
  **Simple Directives**

  A simple directive just consits of a name and a parameter separated by space.
      
  Examples: `root /www/sites;` `gzip on;`
      
  **Blocks**

  On the other hand, blocks consists of several simple directives surrounded by curly braces.
      
  Example:
  ```
  location / {
    root /www/sites;
  }
  ```

### Array Directives
- can be specified multiple times.
- inherited by default in child contexts.
- can be over-ridden in child context.
- access_logs, fastcgi_param can be best examples of array directives.

Example:

```
nginx.conf
----------

access_log /var/log/nginx/access.log;
access_log /var/log/nginx/access.custom.log <custom_format>;

http {
  server {
    location /image {
      access_log /var/log/nginx/access.image.log; // over-rides the global access_log location for /image path
    }
  }
}
```

### Standard Directives
- can be declared only once. If declared again, the second declaration will override the first one.
- will be inherited in all child contexts.

Example:

```
server {
  root /www/sites;

  location /images {
    root /www/images; # Here all the /images/xxx will be served from /www/images folder
  }
}
```

### Action Directives
- redirect and rewrite are examples of action directives. These are described in the later sections.

### Context
- Context can be treated as a scope in a programming language like ruby.
- Context can be better understood by looking at the nginx.conf

```
# main context
user  nginx; # directive in main context
worker_processes  1;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;

events { # events context
  worker_connections  1024; # directive in events context
}

http { # http context
  include       /etc/nginx/mime.types; # directive in http context
  access_log  /var/log/nginx/access.log  main;

  server {          # server context
    listen 80;      # directive in server context

    location / { # location context
      root /var/www/html; # directive in location context
    }
  }
}
```

- Main context sets up directives globally for nginx. Can't override the directives set in global context and are not inherited into the other contexts.

- http and events reside under main context, server resides in http context and location resides in server context.
```
  main context
    events context
    http context
      server context
        location context
```

### Variables

- Variables in nginx, like in any programming language can be used for storing a value which can be retrieved at a later point of time.
```
Syntax:	set $variable value;
Context: server, location, if
```


- Replace your nginx.conf with the following, and reload the nginx(`nginx -s reload`).

```
events {}

http {
    server {
        listen 80;
        set $h_name 'www.ramp.com';

        location / {
            return 200 $h_name;
        }
    }
}
``` 


- We can also interpolate,

```
events {}

http {
    server {
        listen 80;
        set $h_name 'www.ramp.com';

        location / {
            return 200 $h_name;
        }

        location /image_url {
            return 200 "https://$h_name/image_uri";
        }
    }
}
```

- Open your favourite browser and try hit http://localhost:80/ and http://localhost:80/image_url

> Do not forgot to reload the nginx server after changing the configuration every time.

- Nginx also comes with a lot of built in variables which can be used directly [Nginx Variables](http://nginx.org/en/docs/varindex.html)

### Http Directive

### Server Directive

### Location Directive
- Location directive/block resides inside the `Server Directive`.
- Decides how to process the different uri's.
- When a request for resource comes to the nginx server, the uri is matched with one of the location block and is served accordingly.

Syntax:

```
location optional_modifier location_match {
    ----------
    -------
    ---
}
```

Modifiers:
  ```
  none - Prefix match
  =    - Exact match
  ~    - Case Sensitive regular expression match
  ~*   - Case insensitive regular expression match
  ^~   - Preferential Prefix match(prevents any regular expression matching.)
  ```

Examples:

```
location /temp {
   # Matches everything that starts with /temp and continues searching untill more specific block is found else it will use this.
   # http://localhost:80/temp ✅
   # http://localhost:80/temp/1 ✅
   # http://localhost:80/temp/1/rand ✅
}
```

```
location ^~ /temp {
   # Matches everything that starts with /temp and then stop searching.
   # http://localhost:80/temp ✅
   # http://localhost:80/temp/1 ✅
}
```

```
location = /ramp {
  # Only matches the uri's /ramp
  # http://localhost:80/ramp ✅
  # http://localhost:80/ramp/1 ❌
}
```

```
location ~ /*.(png|ico|gif|jpg|jpeg|css|js)$ {
  # Matches all the uri's which end with .png or .ico and etc with case matching as stated.
  # http://localhost:80/1.png ✅
  # http://localhost:80/1.ico ✅
  # http://localhost:80/1.gif ✅
  # http://localhost:80/1.jpg ✅
  # http://localhost:80/1.jpeg ✅
  # http://localhost:80/1.css ✅
  # http://localhost:80/1.js ✅
  # http://localhost:80/1.PNG ❌
}
```

```
location ~* /*.(png|ico|gif|jpg|jpeg|css|js)$ {
  # Case insensitive match of the above.
  # http://localhost:80/1.png ✅
  # http://localhost:80/1.PNG ✅
}
```

Priority order:

`Exact(=)` > `Preferential Prefix(^~)` > `RE match(~*, ~)` > `Prefix`

### Logging

- nginx uses 2 log files
   i. error.log - for logging the resouces which are not found
   ii. access.log - for logging all the requests to the made to the server.

- logging is enabled by default.


Example:
```
server {
  listen 80;
  server_name www.ramp.com;
  root /www/sites;

  error_log /var/log/nginx/error.log;
  access_log /var/log/nginx/access.log;

  listen /images {
    access_log /var/log/nginx/images_access.log; # we can specifiy different files for different locations.
  }

  listen /docs {
    access_log /var/log/nginx/docs_access.log;
    access_log /var/log/nginx/access.log      # logs all /docs/xxx requests to both docs_access and access.log files.
  }

  listen /temp {
    access_log off; # disables the logs for all /temp/xxx requests
  }
}
```

[More on loggin](https://docs.nginx.com/nginx/admin-guide/monitoring/logging/)

### Return

- A return can be used to perfrom things like permantent redirect, temperory redirect, redirect all/specific traffic to https and etc.

Syntax: `return <status_code> <text>/<url>`

Examples

```
server {
  listen 80 default_server;
  server_name www.ramp.com;
  return 301 https://$host$request_uri; # Redirects all http traffic to https
}
```

```
location / {
  return 200 "ok"; # Returns a 200 status code with a plain-text ok.
  return 302 http://example.com/articles # temperory redirects
  return 301 http://example.com/articles # permanent redirects
}
```

### Rewrite

- Like return, rewrite is also used for temperory/permanent redirects, redirecting a  user from non-www to www version and etc.
- `redirect` directive can be used only in **server**, **location** and **if** directives

Syntax: `rewrite regex URL [optional_flag]`

Flags:
  permanent - permanent redirect (301)
  rewrite   - temperory redirects(302)
  break     - stops processing of rewrite.
  last      - stop search of rewritten url in current block and use the changed uri for further lookup/re-evaluation(rewrites)

Examples:

```
server {
  # Permanent redirect to new URL
  server_name olddomain.com;
  rewrite ^/(.*)$ https://newdomain.com/$1 permanent;
}

server {
  # temperory redirect to new URL
  server_name olddomain.com;
  rewrite ^/(.*)$ https://newdomain.com/$1 redirect;
}
```

```
location /data/ {
    rewrite ^(/data/.*)/geek/(\w+)\.?.*$ $1/linux/$2.html break;
    return  403;
}

$1 matches all the string that begin with /data/
$2 is any word that comes after /geek
*$ is the extension of the request uri

url/data/distro/geek/test.php -> url/data/distro/linux/test.html
```

```
location /music/ {
  rewrite ^/music/(.*)$ /music/stream?file_name=$1.mp3;

  /music/song1 -> /music/stream?file_name=song1.mp3
  /music/song2 -> /music/stream?file_name=song2.mp3
}
```

```
if ($scheme = "http") {
  rewrite ^ https://www.ramp.com$uri permanent;
}
```

- break vs last flags

```
location /data/ {
  rewrite ^(/data/.*)/geek/(\w+)\.?.*$ $1/linux/$2.html break;
  return  403;
}
```

If we had `last` instead of `break` in the above rewrite, nginx will keep processing the same request for max 10 times with finally returning 500 status code.

- If we want all the redwrites to be logged, just ensure that you have an `error_log` specified with `rewrite_log` set to on

```
nginx.conf
----------

error_log /var/log/nginx/error.log notice;
rewrite_log on;
```

### Try Files

- Try can be better understood with an example

```
server {
  listen 80;
  server_name localhost;
  root /www/sites/;

  location / {
    try_files $uri /instructions.txt /temp @404; # No re-evaluation happens after named location
  }

  location /temp {
    return 200 "Found in temp folder";
  }

  location @404 {
    return 404 "Not found";
  }
}
```

http://localhost:80/index.html
  - If index.html is available in /www/sites/, it will be served,
  - If index.html is not available, then instructions.txt is served if available
  - If instructions.txt is not available, then the same is searched in /www/sites/temp/
  - If /www/sites/temp/instructions.txt is not available, then the request will be matched with named location 404(name to a location can be assigned using @)

### Worker Processes

- A worker process is the one which do the actual processing of the requests.
- For better performance, the number of worker processes should be equal to the number of cores of CPU.
- To get the number of cores of CPU of server, use `nproc` or `lscpu`

`worker_processes = No of cores of CPU`

- To have the best performance, set it to auto `worker_processes auto;`

### Worker Connections

- No of simultaneous connections
- No of connections each worker_processes can handle.
- To get the value of this set it to `ulimit -n`

`worker_connections 1024;`

- The maximum number of clients served by nginx can be obtained as
  `clients = worker_processes * worker_connections`
