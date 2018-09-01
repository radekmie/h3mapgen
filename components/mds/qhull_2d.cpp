#include "qhull_2d.hpp"
#include "utils.hpp"
#include <igl/slice_mask.h>

using Eigen::Matrix2Xd;
using Eigen::MatrixX2d;
using Eigen::RowVector2d;
using Eigen::RowVectorXd;

MatrixX2d link(MatrixX2d a, MatrixX2d b)
{
    return vstack(a, b.bottomRows(b.rows() - 1));
}

Matrix2Xd edge(RowVectorXd a, RowVectorXd b)
{
    return vstack(a, b);
}

MatrixX2d dome(MatrixX2d sample, MatrixX2d base)
{
    RowVector2d h = base.row(0);
    RowVector2d t = base.row(1);

    Eigen::Matrix2d p;
    p << 0, -1, 1, 0;

    RowVectorXd dists = (sample.rowwise() - h) * (p * (t - h).transpose());
    MatrixX2d outer = igl::slice_mask(sample, dists.array() > 0, 1);

    if (outer.rows() > 0)
    {
        MatrixX2d pivot = sample.row(argmax(dists));
        return link(dome(outer, edge(h, pivot)), dome(outer, edge(pivot, t)));
    }
    return base;
}

MatrixX2d qhull2D(MatrixX2d sample)
{
    if (sample.rows() > 2)
    {
        Eigen::VectorXd axis = sample.col(0);
        int idxmin = argmin(axis);
        int idxmax = argmax(axis);
        Eigen::Matrix2d base = vstack(sample.row(idxmin), sample.row(idxmax));
        return link(dome(sample, base), dome(sample, base.colwise().reverse()));
    }
    return sample;
}
