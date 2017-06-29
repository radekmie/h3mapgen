# Usage

Run `python embed_graph.py path_to_graph mode`.

Example: `python embed_graph.py graphs/g1`.

Graph should be represented by a text file. First line contains one integer (number of vertices). The rest of the lines have the following structure: first string (until the first whitespace) in a line is the ID of the node, after that there is an integer representing size, the rest is a list of node's neighbors (represented by their IDs). Examples are in the `graphs` folder. DO NOT put a new line at the end of the file, it will be interpreted as a vertex with no neighbors.

Script produces a text file with vertex embeddings and a plot, both are saved in `path_to_graph` directory. Dotted lines represent Voronoi borders. 
"Bad edges" is the number of edges in the graph that cross an area they don't belong to. It shows incorrect number for graphs with different node sizes at the moment, so ignore it for now.

I couldn't get rid of very large zones forming near the edges of a map. For now, I greyed out the points that are further than 0.5 from the nearest embedding point. This is probably not the best solution in the long run.

UPDATE: The program now rotates and scales the embeddings to make them fill map space better.

# Transforming a graph

Let's say we have two connected vertices, `v` and `u` with sizes 3 and 8, respectively. I tried to just weight the edge `u-v` in a few different ways, but it didn't work very well. I ended up splitting each vertex `x` into `size(x)` vertices (`v` becomes `v_1`, `v_2`, `v_3`, for example). I chose to make those into a cycle (`v_1-v_2`, `v_2-v_3`, `v_3-v_1`). Clique gave bad results, the embeddins were too close to each other. Then I have to connect `v` and `u` in the transformed graph. I tried connecting each `v_i` with each `u_j`, it looked bad for big nodes. I found better way: connect one random `v_i` with one random `u_j`. The script uses this method.

# Gravity pulling

Points are now pulled towards the map borders. More detailed description (hopefully) soon.

Results with `_pregrav` are saved before pulling, for comparison.

# Sources

`sammon.py` comes from https://github.com/tompollard/sammon

`min_bounding_rect.py` and `qhull_2d.py` come from https://github.com/dbworth/minimum-area-bounding-rectangle


About graph embeddings:

[1] http://www.stat.yale.edu/~lc436/papers/JCGS-mds.pdf

[2] http://www.graphviz.org/Documentation/GKN04.pdf

[3] https://en.wikipedia.org/wiki/Sammon_mapping

[4] https://en.wikipedia.org/wiki/Multidimensional_scaling

[5] https://www.codeproject.com/Articles/43123/Sammon-Projection
