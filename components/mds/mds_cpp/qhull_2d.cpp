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

// test
// int main() {
//     mat a = {
//         {0.46139225,  0.01608542},
//         {0.93274524,  0.26489567},
//         {0.32466116,  0.86086489},
//         {0.22261092,  0.31779705},
//         {0.59410701,  0.1191493 },
//         {0.1569244 ,  0.05827084},
//         {0.61999389,  0.75780352},
//         {0.10056238,  0.44661418},
//         {0.9609345 ,  0.20627358},
//         {0.86056549,  0.19085841}
//     };
//     std::cout << qhull2D(a);
//     return 0;
// }