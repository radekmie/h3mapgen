#ifndef min_bounding_rect_hpp
#define min_bounding_rect_hpp

#include <Eigen/Dense>

std::tuple<double, double, double> minBoundingRect(Eigen::MatrixX2d hull_points_2d);

#endif