#! /bin/bash
g++ main.cpp graph.cpp sammon.cpp qhull_2d.cpp min_bounding_rect.cpp \
postproc.cpp -o mds -std=c++11 -O2 -DARMA_DONT_USE_WRAPPER \
-DARMA_USE_BLAS -DARMA_USE_LAPACK -lopenblas -llapack -pedantic -Wall -Wextra \
-Wformat -Wfloat-equal -W -Wreturn-type -pedantic-errors -Wundef
