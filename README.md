# h3mapgen
An attempt to build a comprehensive map generator for Heroes of Might and Magic III

## Design

<p align="center">
  <img src="design.png" alt="Design" height="357">
</p>

<details>
<summary>

[nomnoml](http://nomnoml.com/) source

</summary>

```
#arrowSize: 0.75
#direction: right
#fill: transparent
#font: monospace
#leading: 1
#lineWidth: 2
#padding: 10
#spacing: 25
#stroke: #000
#title: design

#.vertical: bold center direction=down

[<reference> H3PGM |
  [<vertical> Meta |
    [seed] -> [LML]
    [LML] -> [MLML]
    [MLML] -> [MDS]
  ]

  [<vertical> Renderable |
    [CA] -> [Plugins]
    [Plugins] -> [CA]
  ]

  [<start>] -> [Meta]
  [Meta] -> [Voronoi]
  [Voronoi] -> [Renderable]
  [Renderable] --> [.h3m]
  [Renderable] -> [<end> .]
]
```

</details>

## Setup

```shell
$ git submodule update --init --recursive
$ make
```

## Run generator
From the project root directory run `lua generate.lua initial-h3pgm`. The output from all stages of generation is saved in `output/<seed>_<players>`. That directory should contain these directories and files:

| File             | Description                                |
| ---------------- | ------------------------------------------ |
| `dumps/*.h3m`    | State at various moments (map).            |
| `dumps/*.h3pgm`  | State at various moments.                  |
| `imgs/LML-*.dot` | LML at different evolution stage (source). |
| `imgs/LML-*.png` | LML at different evolution stage.          |
| `LML.dot`        | Final LML (source).                        |
| `LML.png`        | Final LML.                                 |
| `emb.png`        | Embedding result.                          |
| `emb.txt`        | Embedding coordinates.                     |
| `graph.txt`      | Graph structure.                           |
| `map.h3m`        | _Playable_ map.                            |
| `sfp.txt.*`      | SFP algorithm arguments.                   |

Example: `lua generate.lua '>'`.

## Run GUI
There's no single executable file yet, but you can run it with [love2d](https://love2d.org/):

```sh
love h3mapgen.love
```

## Random notes of Kuba S.:
- In case you don't know that: the first rule is that the code in `master` is compilable at all times. You should check that before commiting.
- I've created a separate branch for development of cellular automata. Creating branches for other parts of the project is highly encouraged.
- File `src/cellular/board.hpp` contains declaration of `Board` and `Cell` as well as some tools and functions of general use (not only for cellular automata). It seems reasonable to me for us to include this file at every stage that makes use of the game board represented by a grid of black/white cells instead of creating several inconsistent abstractions. Also, I think that the declarations should be replaced by proper class definitions soon (for the sake of convinience). Feel free to work on it.
- I've been storing the intervening board-like results in a text files (see `output/` directory). To preserve the consistency of the format, please use the `print_board` and `load_board` functions from `src/cellular/board.hpp`.
- My english isn't perfect - I'm aware of that. Please correct every mistake you spotted. I'd appreciate that.
