#ifndef postproc_hpp
#define postproc_hpp

#include <Eigen/Dense>

#define RowArray2d Eigen::Array<double, 1, 2>

Eigen::MatrixX2d pull_points(
    Eigen::MatrixX2d points,
    Eigen::MatrixX2d grav_points,
    Eigen::VectorXd mass,
    double g);

Eigen::MatrixX2d make_grav_points(
    int points_per_edge,
    Eigen::Vector2d xlim,
    Eigen::Vector2d ylim);

Eigen::MatrixX2d scale(
    Eigen::MatrixX2d X,
    bool with_mean = true,
    bool with_std = true);

Eigen::MatrixX2d squeeze(
    Eigen::MatrixX2d data,
    Eigen::Vector2d lxy = {0, 0},
    Eigen::Vector2d hxy = {1, 1});

#endif