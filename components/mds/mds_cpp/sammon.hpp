#ifndef sammon_hpp
#define sammon_hpp

#ifndef armadillo
#include <armadillo>
#endif

arma::mat euclid(arma::mat A, arma::mat B);
std::pair<arma::mat, double> sammon(arma::mat D, int display = 2,
                                    int maxhalves = 20, int maxiter = 500,
                                    double tolfun = 1e-9);

#endif