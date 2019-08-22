## Hi, Welcome to my nginx github page.

1. [What is nginx?](https://www.nginx.com/resources/glossary/nginx/)
2. Basics
  * [Directives](#directives)
  * [Context](#context)
  * [Variables](#variables)

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

