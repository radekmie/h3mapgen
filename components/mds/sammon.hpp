#ifndef sammon_hpp
#define sammon_hpp

#include <Eigen/Dense>

Eigen::MatrixXd euclid(Eigen::MatrixX2d A, Eigen::MatrixX2d B);

std::pair<Eigen::MatrixX2d, double> sammon(
    Eigen::MatrixXd D,
    int display = 2,
    int maxhalves = 20,
    int maxiter = 500,
    double tolfun = 1e-9);

#endif