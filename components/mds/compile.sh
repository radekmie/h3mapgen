#! /bin/bash
g++ -I /usr/local/include/ -I /usr/local/include/eigen3/ \
main.cpp graph.cpp sammon.cpp qhull_2d.cpp min_bounding_rect.cpp \
postproc.cpp -o mds -std=c++11 -O2 -pedantic -Wall -Wextra \
-Wformat -Wfloat-equal -W -Wreturn-type -pedantic-errors -Wundef
