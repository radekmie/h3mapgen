#! /bin/bash
g++ embed_graph.cpp graph.cpp sammon.cpp qhull_2d.cpp min_bounding_rect.cpp \
postproc.cpp -o embed_graph -std=c++11 -O2 -DARMA_DONT_USE_WRAPPER \
-DARMA_USE_BLAS -DARMA_USE_LAPACK -lopenblas -llapack
