#ifndef utils_hpp
#define utils_hpp

#include <Eigen/Dense>
#include <igl/mat_max.h>
#include <igl/mat_min.h>

Eigen::MatrixXd vstack(Eigen::MatrixXd, Eigen::MatrixXd);
Eigen::MatrixXd hstack(Eigen::MatrixXd, Eigen::MatrixXd);

int argmax(Eigen::VectorXd);
int argmin(Eigen::VectorXd);

Eigen::MatrixXd inv_nonzero(Eigen::MatrixXd, double def_value = 0.0);

Eigen::Vector2d colwise_stddev(Eigen::MatrixX2d);

#endif
