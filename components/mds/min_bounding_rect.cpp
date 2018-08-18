#define _USE_MATH_DEFINES

#include <cmath>
#include <iostream>
#include <cfloat>
#include "min_bounding_rect.hpp"
#include <igl/unique.h>

using Eigen::MatrixX2d;

std::tuple<double, double, double> minBoundingRect(MatrixX2d hull_points_2d)
{
    // Compute edges (x2 - x1, y2 - y1)
    MatrixX2d edges(hull_points_2d.rows() - 1, 2);
    for (unsigned i = 0; i < edges.rows(); i++)
    {
        double edge_x = hull_points_2d(i + 1, 0) - hull_points_2d(i, 0);
        double edge_y = hull_points_2d(i + 1, 1) - hull_points_2d(i, 1);
        edges.row(i) << edge_x, edge_y;
    }

    // Calculate edge angles atan2(y/x)
    Eigen::VectorXd edge_angles =
        edges.col(1).binaryExpr(edges.col(0), std::ptr_fun(::atan2));

    // Check for angles in 1st quadrant
    for (unsigned i = 0; i < edge_angles.rows(); i++)
    {
        // want strictly positive answers
        edge_angles(i) = std::fabs(std::remainder(edge_angles(i), M_PI_2));
    }

    // Remove duplicate angles
    igl::unique(edge_angles, edge_angles);

    // Test each angle to find bounding box with smallest area
    // rot_angle, area, width, height
    double best_angle = 0;
    double best_area = DBL_MAX;
    double best_width = 0;
    double best_height = 0;

    for (unsigned i = 0; i < edge_angles.rows(); i++)
    {
        // Create rotation matrix to shift points to baseline
        Eigen::Matrix2d R;
        R << std::cos(edge_angles(i)),
            std::cos(edge_angles(i) - M_PI_2),
            std::cos(edge_angles(i) + M_PI_2),
            std::cos(edge_angles(i));

        // Apply this rotation to convex hull points
        Eigen::Matrix2Xd rot_points = R * hull_points_2d.transpose();

        // Find min/max x,y points
        double min_x = rot_points.row(0).minCoeff();
        double max_x = rot_points.row(0).maxCoeff();
        double min_y = rot_points.row(1).minCoeff();
        double max_y = rot_points.row(1).maxCoeff();

        // Calculate height/width/area of this bounding rectangle
        double width = max_x - min_x;
        double height = max_y - min_y;
        double area = width * height;

        // Store the smallest rect found first
        // (a simple convex hull might have 2 answers with same area)
        if (area < best_area)
        {
            best_angle = edge_angles(i);
            best_area = area;
            best_width = width;
            best_height = height;
        }
    }

    // rot_angle, width, height
    return std::make_tuple(best_angle, best_width, best_height);
}
