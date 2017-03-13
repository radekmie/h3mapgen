# h3mapgen
An attempt to build a comprehensive map generator for Heroes of Might and Magic III

## Repo tree:
It's subject to discussion although this schema seems reasonable to me.
```
bin/
    generator.exe
    object1.o *
    object2.o *
    ...
conf/
    voronoi.conf
    ...
doc/
    user_gide.txt
    ...
lua/
    script1.lua
    ...
output/
    intervening_result1
    intervening_result2
    nice_map.h3m
    ...
src/
    voronoi/
    cellular/
    ...
test/
    test_input1
    ...
generator.sh
Makefile

```
\* For now the `.o` files are built in the `src` directory since this way makes the Makefile tremendously simple.


## Random notes:
- In case you don't know that: the first rule is that the code in `master` is compilable at all times. You should check that before commiting.
- I've created a separate branch for development of cellular automata. Creating branches for other parts of the project is highly encouraged.
- File `src/cellular/board.hpp` contains declaration of `Board` and `Cell` as well as some tools and functions of general use (not only for cellular automata). It seems reasonable to me for us to include this file at every stage that makes use of the game board represented by a grid of black/white cells instead of creating several inconsistent abstractions. Also, I think that the declarations should be replaced by proper class definitions soon (for the sake of convinience). Feel free to work on it.
- I've been storing the intervening board-like results in a text files (see `output/` directory). To preserve the consistency of the format, please use the `print_board` and `load_board` functions from `src/cellular/board.hpp`.
- My english isn't perfect - I'm aware of that. Please correct every mistake you spotted. I'd appreciate that.

Kuba S.
