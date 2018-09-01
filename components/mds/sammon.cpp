#include <iostream>
#include "sammon.hpp"
#include "utils.hpp"

using Eigen::MatrixX2d;
using Eigen::MatrixXd;

std::normal_distribution<double> distribution(0, 1);

// pairwise euclidean distance
MatrixXd euclid(MatrixX2d A, MatrixX2d B)
{
    MatrixXd dotsAA = (A * A.transpose()).diagonal().replicate(1, B.rows());
    MatrixXd dotsBB =
        (B * B.transpose()).diagonal().transpose().replicate(A.rows(), 1);
    MatrixXd dotsAB = A * B.transpose() * 2;
    MatrixXd dist = (dotsAA + dotsBB - dotsAB).cwiseSqrt();
    dist = (dist.array().isNaN()).select(0, dist);
    return dist;
}

std::pair<MatrixX2d, double> sammon(
    MatrixXd D, std::default_random_engine &generator,
    int display, int maxhalves, int maxiter, double tolfun)
{
    int dim = 2;

    int N = D.rows();
    double scale = 0.5 / D.sum();
    MatrixXd Dinv = inv_nonzero(D);

    auto energy = [=](MatrixXd emb_dists) {
        return ((D - emb_dists).array().pow(2) * Dinv.array()).sum();
    };

    auto normal = [&](int, int) { return distribution(generator); };
    MatrixX2d emb = MatrixX2d::NullaryExpr(N, dim, normal);

    MatrixXd d = euclid(emb, emb);
    MatrixXd dinv = inv_nonzero(d);

    double E = energy(d);

    Eigen::VectorXd delta_sums;
    MatrixXd delta;
    MatrixXd dinv3;
    MatrixX2d gradient;
    MatrixX2d hessian;
    MatrixX2d step;
    MatrixX2d emb2;
    MatrixX2d emb_old;

    for (int i = 0; i < maxiter; i++)
    {
        delta = dinv - Dinv;
        delta_sums = delta.rowwise().sum();
        gradient = (delta * emb).array() -
                   (emb.array().colwise() * delta_sums.array());
        dinv3 = dinv.array().pow(3);
        emb2 = emb.array().pow(2);

        hessian = (dinv3 * emb2);
        hessian = hessian.array().colwise() - delta_sums.array();
        hessian = hessian - (2 * emb).cwiseProduct(dinv3 * emb);
        hessian = hessian.array() +
                  emb2.array().colwise() * (dinv3.rowwise().sum()).array();

        step = -gradient.cwiseQuotient(hessian.cwiseAbs());
        emb_old = emb;

        double E_new = E;
        for (int j = 0; j < maxhalves; j++)
        {
            emb = emb_old + step;
            d = euclid(emb, emb);
            dinv = inv_nonzero(d);
            E_new = energy(d);
            if (E_new < E)
                break;
            else
                step /= 2;

            if (j == maxhalves - 1)
                std::cout << "Warning: maxhalves exceeded. "
                             "Sammon mapping may not converge...\n";
        }

        if (std::fabs((E - E_new) / E) < tolfun)
        {
            if (display > 0)
                std::cout << "TolFun exceeded: Optimisation terminated\n";
            break;
        }

        E = E_new;
        if (display > 1)
            std::cout << "epoch = " << i << ": E = " << E * scale << "\n";
    }

    return std::make_pair(emb, E * scale);
}
