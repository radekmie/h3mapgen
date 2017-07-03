#!/bin/bash

export LUA_CPATH=homm3lua/dist/?.so
export LUA_PATH=bin/?.lua

# $1 = mlml
# $2 = players
# $3 = size
# $4 = sectors

_conf="bin/config.cfg"
_mlml="bin/_test/$1.h3pgm"
_path="output/$1_$2"

cell="$_path/cell.txt"
emb="$_path/emb"
graph="$_path/graph.txt"
map="$_path/map.h3m"
mds="$_path/emb.txt"
pgm="$_path/mlml.h3pgm"
vor1="$_path/map.txt"
vor2="$_path/mapText.txt"

mkdir -p $_path
lua5.3 bin/test_mlml.lua $_mlml $pgm $graph $2 $_conf
python MDS/embed_graph.py $graph $emb
bin/voronoi $mds $vor1 $3 $3 $4 $4
bin/cellular 0.5 1 2 < $vor1 > $cell
# sed 's/./& /g' $cell | grep --color '\$'
lua5.3 homm3lua/homm3luatest/init.lua $pgm $vor2 $cell $map
