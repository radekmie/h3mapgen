# h3mapgen
An attempt to build a comprehensive map generator for Heroes of Might and Magic III

# Run generator
From the project root directory run `bash run.sh graph_name num_players`.
File called `graph_name`.h3pgm should be in bin/_test directory. The output from all stages of generation is saved in `output/<graph_name>_<num_players>`. That directory should contain 8 files:

- `*graph.txt` with the graph structure
- two pngs with graph embedding results
- two txts with coordinates of the embeddings
- `*map.txt` with zone borders after running voronoi
- `*mapText.txt` with filled zones
- `*cell.txt` with the result CA result

Example: results of `bash run.sh test-1 4` and `bash run.sh test-1 8` are in output folder.

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
homm3lua/
    (lua API to .h3m format)
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
