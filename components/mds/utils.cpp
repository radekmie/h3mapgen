#include "utils.hpp"

using Eigen::MatrixX2d;
using Eigen::MatrixXd;
using Eigen::Vector2d;
using Eigen::VectorXd;
using Eigen::VectorXi;

MatrixXd vstack(MatrixXd x1, MatrixXd x2)
{
    assert(x1.cols() == x2.cols());
    MatrixXd res(x1.rows() + x2.rows(), x1.cols());
    res << x1, x2;
    return res;
}

MatrixXd hstack(MatrixXd x1, MatrixXd x2)
{
    assert(x1.rows() == x2.rows());
    MatrixXd res(x1.rows(), x1.cols() + x2.cols());
    res << x1, x2;
    return res;
}

int argmax(VectorXd v)
{
    VectorXd y;
    VectorXi i;
    igl::mat_max(v, 1, y, i);
    return i(0);
}

int argmin(VectorXd v)
{
    VectorXd y;
    VectorXi i;
    igl::mat_min(v, 1, y, i);
    return i(0);
}

MatrixXd inv_nonzero(MatrixXd x, double def_value)
{
    return (x.array() != 0).select(x.cwiseInverse(), def_value);
}

Vector2d colwise_stddev(MatrixX2d x)
{
    Eigen::RowVector2d means = x.colwise().mean();
    return (x.rowwise() - means).array().pow(2).colwise().mean().cwiseSqrt();
}