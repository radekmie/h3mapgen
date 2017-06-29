#!/bin/bash

lua_out="$1.txt"
graph_file="$1_graph.txt"
mds_out="$1_emb.txt"
vor_out="$1_map.txt"
cell_out="$1_cell.txt"
path="output/$1_$2"


mkdir -p $path
cd bin
lua5.3 test_mlml.lua $1 $2
cd ..
mv bin/_test/$lua_out $path/$graph_file

python MDS/embed_graph.py $path/$graph_file $path/"$1_emb"

bin/voronoi $path/$mds_out $path/$vor_out

bin/cellular 0.5 1 2 < $path/$vor_out > $path/$cell_out

sed 's/./& /g' $path/$cell_out | grep --color '\$'
