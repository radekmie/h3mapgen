#!/bin/bash
set -x

mkdir -p output

# Later on, this file shall look similar to this schema:
# ./bin/grammar < output/user_input > output/player_graph
# ./bin/multiplicat < output/player_graph > output/whole_graph
# ./bin/embed < output/whole_graph > output/embedded
# ./bin/voronoi < output/embedded > output/zones
# ./bin/cellular < output/zones > output/terrain
# ...

echo 'a' | ./bin/voronoi  # input/output files should goes here instead of being hardcoded
cat mapa.txt | head -n 1 > output/voronoi90x90 
cat mapa.txt | tail -n +2 | tr '.' '$' | tr '0123456789' ' ' >> output/voronoi90x90
./bin/cellular 0.5 1 2 < output/voronoi90x90 > output/cellular90x90


#./bin/cellular 0.5 1 2 < test/zones33x33 > output/terrain33x33
