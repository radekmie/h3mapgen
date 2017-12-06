#ifndef min_bounding_rect_hpp
#define min_bounding_rect_hpp

#ifndef armadillo
#include <armadillo>
#endif

std::tuple<double, double, double> minBoundingRect(arma::mat hull_points_2d);

#endif