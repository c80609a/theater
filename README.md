# Preparing

```
$ ruby -v  # ruby 2.3.3p222
$ rails -v # Rails 5.2.0
$ rails new theater -T -d postgresql --api
$ cd theater
$ echo ruby-2.3.3 > .ruby-version
$ echo "/.idea" >> .gitignore

$ git add -A
$ git commit -m "initial commit"
$ git remote add origin git@github.com:c80609a/theater.git
$ git push -u origin master

$ sudo -u postgres psql
> CREATE DATABASE theater;

> CREATE ROLE theater_user;
> ALTER USER theater_user WITH PASSWORD '12345678';
> ALTER ROLE theater_user WITH LOGIN;
> ALTER ROLE theater_user WITH CREATEDB;
> GRANT ALL ON DATABASE theater TO theater_user;

> CREATE DATABASE theater_test;
> GRANT ALL PRIVILEGES ON DATABASE theater_test TO theater_user;
> ALTER DATABASE theater_test OWNER TO theater_user;
> \q
```

# FLOW

See git log.