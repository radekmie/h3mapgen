#ifndef sammon_hpp
#define sammon_hpp

#ifndef armadillo
#include <armadillo>
#endif

arma::mat euclid(arma::mat A, arma::mat B);
std::pair<arma::mat, double> sammon(arma::mat D, int display, int maxhalves,
                                    int maxiter, double tolfun);

#endif