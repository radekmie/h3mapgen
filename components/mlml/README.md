## LogicMapLayout info

Just a short note here


### Testing
Call `test_lml.lua` from lua5.3, it runs configs from the [_test](_test) directory, should be strightforward

To draw graph images [Graphviz](http://www.graphviz.org/) is required

(Proposed Lua IDE if anyone needs itL [ZeroBrane Studio](https://studio.zerobrane.com/).)

### h3pgm

Files h3pgm are Lua configs storing map info

- `LML_init` contains initial node - put here what you want to test, format should be easy to grasp
- `LML_graph` contains generated graph
- `LML_interface` contains graph's interface which is input to MutiLML


### Grammar
Only simple productions for now, see [LogicMapLayout/Grammar/Grammar.lua](LogicMapLayout/Grammar/Grammar.lua)
