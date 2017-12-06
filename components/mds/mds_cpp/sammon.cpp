#include <iostream>
#include "sammon.hpp"

using namespace arma;

// pairwise euclidean distance
mat euclid(mat A, mat B) {
    mat dotsAA = repmat(diagvec(A * A.t()), 1, B.n_rows);
    mat dotsBB = repmat(diagvec(B * B.t()).t(), A.n_rows, 1);
    mat dotsAB = A * B.t() * 2;
    mat dist = sqrt(dotsAA + dotsBB - dotsAB);
    dist.replace(datum::nan, 0);
    return dist;
}

std::pair<mat, double> sammon(mat D, int display = 2, int maxhalves = 20,
                              int maxiter = 500, double tolfun = 1e-9) {
    int dim = 2;

    // Remaining initialisation
    int N = D.n_rows;
    double scale = 0.5 / accu(D);
    D += eye<mat>(N, N);
    mat Dinv = 1.0 / D; // Returns inf where D = 0.
    Dinv.replace(datum::inf, 0);

    mat y = randn<mat>(N, dim);

    mat one = ones<mat>(N, dim);
    mat d = euclid(y, y) + eye<mat>(N, N);
    mat dinv = 1.0 / d; // Returns inf where d = 0.
    dinv.replace(datum::inf, 0);
    double E = accu(pow(D - d, 2) % Dinv);

    int i;
    for (i = 0; i < maxiter; i++) {
        mat delta = dinv - Dinv;
        mat deltaone = delta * one;
        mat g = (delta * y) - (y % deltaone);
        mat dinv3 = pow(dinv, 3);
        mat y2 = pow(y, 2);
        mat H = (dinv3 * y2) - deltaone - (y * 2) % (dinv3 * y) +
                y2 % (dinv3 * one);
        mat s = -vectorise(g).t() / abs(vectorise(H)).t();
        mat y_old = y;

        // Use step-halving procedure to ensure progress is made
        int j;
        double E_new;
        for (j = 0; j < maxhalves; j++) {
            mat s_reshape = reshape(s, s.size() / 2, 2);
            y = y_old + s_reshape;
            d = euclid(y, y) + eye<mat>(N, N);
            dinv = 1.0 / d; // Returns inf where D = 0.
            dinv.replace(datum::inf, 0);
            E_new = accu(pow(D - d, 2) % Dinv);
            if (E_new < E)
                break;
            else
                s = s / 2;
        }

        // Bomb out if too many halving steps are required
        if (j == maxhalves)
            std::cout << "Warning: maxhalves exceeded. Sammon mapping may "
                      "not converge...\n";

        // Evaluate termination criterion
        if (std::fabs((E - E_new) / E) < tolfun) {
            if (display > 0)
                cout << "TolFun exceeded: Optimisation terminated\n";
            break;
        }

        // Report progress
        E = E_new;
        if (display > 1)
            cout << "epoch = " << i << ": E = " << E * scale << "\n";
    }

    // Fiddle stress to match the original Sammon paper
    E = E * scale;
    return std::make_pair(y, E);
}

// test
// int main() {
//     mat A1 = {
//         {0, 1, 2, 1},
//         {1, 0, 1, 2},
//         {2, 1, 0, 1},
//         {1, 2, 1, 0}
//     };

//     mat A2 = {
//         {0, 1},
//         {1, 0}
//     };

//     std::pair<mat, double> p = sammon(A1);
//     std::cout << std::get<0>(p) << "\n";
//     std::cout << std::get<1>(p);

//     return 0;
// }