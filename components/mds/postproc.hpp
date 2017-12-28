#ifndef postproc_hpp
#define postproc_hpp

#include <armadillo>

arma::mat pull_points(arma::mat points, arma::mat grav_points,
                      arma::vec mass, double g);

arma::mat make_grav_points(int points_per_edge,
                           arma::vec xlim, arma::vec ylim);

arma::mat scale(arma::mat X, bool with_mean = true, bool with_std = true);

arma::mat squeeze(arma::mat data,
                  arma::vec lxy = {0, 0}, arma::vec hxy = {1, 1});

#endif