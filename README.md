# h3mapgen
An attempt to build a comprehensive map generator for Heroes of Might and Magic III

## Setup

```shell
$ git submodule update --init --recursive
$ make
```

## Run generator
From the project root directory run `lua generate.lua players size sectors [seed]`. The output from all stages of generation is saved in `output/<seed>_<players>`. That directory should contain 10 files:

| File              | Description                            |
| ----------------- | -------------------------------------- |
| `cell.txt`        | CA result                              |
| `emb.png`         | Embedding result                       |
| `emb.txt`         | Embedding coordinates                  |
| `emb_pregrav.png` | Embedding result (before gravity)      |
| `emb_pregrav.txt` | Embedding coordinates (before gravity) |
| `graph.txt`       | Graph structure                        |
| `map.h3m`         | _Playable_ map                         |
| `map.txt`         | Zone borders after voronoi             |
| `mapText.txt`     | Filled zones                           |
| `mlml.h3pgm`      | Logic map layout                       |

Example: `bash run.sh 4 72 4` or `bash run.sh 8 144 36`.

## Random notes:
- In case you don't know that: the first rule is that the code in `master` is compilable at all times. You should check that before commiting.
- I've created a separate branch for development of cellular automata. Creating branches for other parts of the project is highly encouraged.
- File `src/cellular/board.hpp` contains declaration of `Board` and `Cell` as well as some tools and functions of general use (not only for cellular automata). It seems reasonable to me for us to include this file at every stage that makes use of the game board represented by a grid of black/white cells instead of creating several inconsistent abstractions. Also, I think that the declarations should be replaced by proper class definitions soon (for the sake of convinience). Feel free to work on it.
- I've been storing the intervening board-like results in a text files (see `output/` directory). To preserve the consistency of the format, please use the `print_board` and `load_board` functions from `src/cellular/board.hpp`.
- My english isn't perfect - I'm aware of that. Please correct every mistake you spotted. I'd appreciate that.

Kuba S.
