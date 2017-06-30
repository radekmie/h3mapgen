#!/bin/bash

lua_out="$1.txt"
mlml_file="bin/_test/$1.h3pgm"
graph_file="$1_graph.txt"
mds_out="$1_emb.txt"
vor_out="$1_map.txt"
vor2_out="$1_mapText.txt"
cell_out="$1_cell.txt"
map_out="$1.h3m"
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

lua5.3 homm3lua/homm3luatest/init.lua $mlml_file $path/$vor2_out $path/$map_out
