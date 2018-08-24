#include "postproc.hpp"
#include "sammon.hpp"
#include "utils.hpp"

using Eigen::ArrayXd;
using Eigen::MatrixX2d;
using Eigen::MatrixXd;
using Eigen::RowVector2d;
using Eigen::Vector2d;
using Eigen::VectorXd;

MatrixX2d pull_points(MatrixX2d points, MatrixX2d grav_points, VectorXd mass,
                      double g)
{
    MatrixXd dists = euclid(points, grav_points).array() + 1;
    MatrixXd dists2 = dists.array().pow(2);
    MatrixXd force =
        g / (dists2.array().rowwise() / mass.array().transpose()).array();

    MatrixXd diffsX(grav_points.rows(), points.rows());
    MatrixXd diffsY(grav_points.rows(), points.rows());

    for (unsigned i = 0; i < grav_points.rows(); i++)
    {
        for (unsigned j = 0; j < points.rows(); j++)
        {
            diffsX(i, j) = grav_points(i, 0) - points(j, 0);
            diffsY(i, j) = grav_points(i, 1) - points(j, 1);
        }
    }

    MatrixXd lengths =
        (diffsX.array().pow(2) + diffsY.array().pow(2)).cwiseSqrt();
    lengths = (lengths.array() == 0).select(1, lengths);
    diffsX = diffsX.cwiseQuotient(lengths).cwiseProduct(force.transpose());
    diffsY = diffsY.cwiseQuotient(lengths).cwiseProduct(force.transpose());
    MatrixX2d shifts = hstack(
        diffsX.colwise().sum().transpose(),
        diffsY.colwise().sum().transpose());
    return points + shifts;
}

MatrixX2d make_grav_points(int points_per_edge, Vector2d xlim, Vector2d ylim)
{
    VectorXd lx = VectorXd::LinSpaced(points_per_edge, xlim(0), xlim(1));
    VectorXd ly = VectorXd::LinSpaced(points_per_edge, ylim(0), ylim(1));

    MatrixX2d res(0, 2);

    MatrixX2d pt1 = hstack(lx, VectorXd::Ones(lx.size()) * ylim(0));
    res = vstack(res, pt1);

    MatrixX2d pt2 = hstack(lx, VectorXd::Ones(lx.size()) * ylim(1));
    res = vstack(res, pt2);

    MatrixX2d pt3 = hstack(VectorXd::Ones(ly.size()) * ylim(0), ly);
    res = vstack(res, pt3.block(1, 0, points_per_edge - 2, 2));

    MatrixX2d pt4 = hstack(VectorXd::Ones(ly.size()) * ylim(1), ly);
    res = vstack(res, pt4.block(1, 0, points_per_edge - 2, 2));

    return res;
}

MatrixX2d scale(MatrixX2d X, bool with_mean, bool with_std)
{
    if (with_mean)
    {
        X = X.rowwise() - X.colwise().mean();
        X.rowwise() -= X.colwise().mean(); // in case of very large values in X
    }
    if (with_std)
    {
        RowArray2d scale_ = colwise_stddev(X);
        scale_ = (scale_.array() == 0).select(1, scale_);

        X = X.array().rowwise() / scale_;
        if (with_mean)
        {
            X.rowwise() -= X.colwise().mean();
        }
    }
    return X;
}

MatrixX2d squeeze(MatrixX2d data, Vector2d lxy, Vector2d hxy)
{
    RowVector2d mins = data.colwise().minCoeff();
    RowVector2d maxs = data.colwise().maxCoeff() - mins;
    MatrixX2d new_data = data.rowwise() - mins;
    new_data.array().rowwise() /= maxs.array();
    new_data.array().rowwise() *= (hxy - lxy).transpose().array();
    new_data.rowwise() += lxy.transpose();
    return new_data;
}
