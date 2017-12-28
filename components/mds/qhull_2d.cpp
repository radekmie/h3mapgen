#include <iostream>
#include "qhull_2d.hpp"

using namespace arma;

// a, b are 2D matrices
mat link(mat a, mat b) {
    return join_vert(a, b.tail_rows(b.n_rows - 1));
}

// a, b are row vectors
mat edge(mat a, mat b) {
    return join_vert(a, b);
}

mat dome(mat sample, mat base) {
    mat h = base.row(0);
    mat t = base.row(1);

    mat p = {
        {0, -1},
        {1,  0}
    };

    mat dists = (sample.each_row() - h) * (p * (t - h).t());
    mat outer = sample.rows(find(dists > 0));

    if (outer.n_rows > 0) {
        mat pivot = sample.row(dists.index_max());
        return link(dome(outer, edge(h, pivot)), dome(outer, edge(pivot, t)));
    } else
        return base;
}

mat qhull2D(mat sample) {
    if (sample.n_rows > 2) {
        mat axis = sample.col(0);
        uvec inds = {axis.index_min(), axis.index_max()};
        mat base = sample.rows(inds);
        return link(dome(sample, base), dome(sample, flipud(base)));
    } else
        return sample;
}
