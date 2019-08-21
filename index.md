## Hi, Welcome to my nginx github page.

1. [What is nginx?](https://www.nginx.com/resources/glossary/nginx/)

  The way nginx and its modules work is determined in the configuration file. By default, the configuration file is named `nginx.conf` and placed in the directory `/usr/local/nginx/conf`, `/etc/nginx`, or `/usr/local/etc/nginx`.
2. Basics
  * [Directives](#directives)
  * [Context](#context)
  * [Variables](#variables)

### Directives

- A directive in nginx consists of a name and parameters separated by a space.
- A directive should always end with a semicolon(;).
- Directives in nginx are of 2 types
    
  **Simple Directives**

  A simple directive just consits of a name and a parameter separated by space.
      
  Examples: `root /www/sites` `gzip on;`
      
  **Blocks**

  On the other hand blocks consists of several simple directives surronded by a curly braces.
      
  Example:
  ```
  location / {
    root /www/sites;
  }
  ```

### Context

### Variables