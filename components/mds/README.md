## Usage

Run `./mds path_to_graph output_file_name [seed]`.

Graph should be represented by a text file. First line contains one integer (number of vertices). The rest of the lines have the following structure: first string (until the first whitespace) in a line is the ID of the node, after that there is an integer representing size, the rest is a list of node's neighbors (represented by their IDs).

## Transforming a graph

Let's say we have two connected vertices, `v` and `u` with sizes 3 and 8, respectively. I tried to just weight the edge `u-v` in a few different ways, but it didn't work very well. I ended up splitting each vertex `x` into `size(x)` vertices (`v` becomes `v_1`, `v_2`, `v_3`, for example). I chose to make those into a cycle (`v_1-v_2`, `v_2-v_3`, `v_3-v_1`). Clique gave bad results, the embeddins were too close to each other. Then I have to connect `v` and `u` in the transformed graph, so I connect one random `v_i` with one random `u_j`.

## About graph embeddings:

[1] http://www.stat.yale.edu/~lc436/papers/JCGS-mds.pdf

[2] http://www.graphviz.org/Documentation/GKN04.pdf

[3] https://en.wikipedia.org/wiki/Sammon_mapping

[4] https://en.wikipedia.org/wiki/Multidimensional_scaling

[5] https://www.codeproject.com/Articles/43123/Sammon-Projection
