```shell
$ make
$ make doc # requires ldoc
$ lua homm3luademo/init.lua # Showcase map
$ lua homm3luatest/init.lua # Map generated from test input
```

### FAQ

* If compilation fail, set `LUAC` and `LUAL` variables in `Makefile` accordingly to your setup.
* If map crashes game at any moment, open it in editor and save it.
