#include "postproc.hpp"
#include "sammon.hpp"

using namespace arma;

mat pull_points(mat points, mat grav_points, vec mass, double g) {
    mat dists = euclid(points, grav_points) + 1;
    mat dists2 = pow(dists, 2);
    mat force = mass.t() * g / dists2.each_row();
    cube diffs = cube(grav_points.n_rows, points.n_rows, 2);
    for (int i = 0; i < grav_points.n_rows; i++)
        for (int j = 0; j < points.n_rows; j++)
            diffs.tube(i, j) = grav_points.row(i) - points.row(j);
    mat lengths = sqrt(sum(pow(diffs, 2), 2));
    lengths.replace(0, 1);
    diffs.each_slice() /= lengths;
    mat movements = sum(diffs.each_slice() % force.t());
    return points + movements;
}

mat make_grav_points(int points_per_edge, vec xlim, vec ylim) {
    vec lx = linspace(xlim(0), xlim(1), points_per_edge);
    vec ly = linspace(ylim(0), ylim(1), points_per_edge);

    mat res = mat(0, 2);

    mat pt1 = join_horiz(lx, ones(lx.size()) * ylim[0]);
    res = join_vert(res, pt1);

    mat pt2 = join_horiz(lx, ones(lx.size()) * ylim[1]);
    res = join_vert(res, pt2);

    mat pt3 = join_horiz(ones(ly.size()) * ylim[0], ly);
    res = join_vert(res, pt3.rows(1, points_per_edge - 2));

    mat pt4 = join_horiz(ones(ly.size()) * ylim[1], ly);
    res = join_vert(res, pt4.rows(1, points_per_edge - 2));

    return res;
}

mat scale(mat X, bool with_mean, bool with_std) {
    if (with_mean) {
        X = X.each_row() - mean(X);
        X.each_row() -= mean(X); // in case of very large values in X
    }
    if (with_std) {
        mat scale_ = stddev(X, 1);
        scale_.replace(0, 1);

        X = X.each_row() / scale_;
        if (with_mean)
            X.each_row() -= mean(X);
    }
    return X;
}

mat squeeze(mat data, vec lxy, vec hxy) {
    mat mins = min(data);
    mat maxs = max(data) - mins;
    mat new_data = data.each_row() - mins;
    new_data.each_row() /= maxs;
    new_data.each_row() %= hxy.t() - lxy.t();
    new_data.each_row() += lxy.t();
    return new_data;
}
