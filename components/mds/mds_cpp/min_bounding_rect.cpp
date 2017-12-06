#include <iostream>
#include <cfloat>
#include "min_bounding_rect.hpp"

using namespace arma;

std::tuple<double, double, double> minBoundingRect(mat hull_points_2d) {
    // Compute edges (x2 - x1, y2 - y1)
    mat edges = mat(hull_points_2d.n_rows - 1, 2); // empty 2 column array
    for (int i = 0; i < edges.n_rows; i++) {
        double edge_x = hull_points_2d(i + 1, 0) - hull_points_2d(i, 0);
        double edge_y = hull_points_2d(i + 1, 1) - hull_points_2d(i, 1);
        edges.row(i) = mat({edge_x, edge_y});
    }

    // Calculate edge angles   atan2(y/x)
    mat edge_angles = atan2(edges.col(1), edges.col(0));

    // Check for angles in 1st quadrant
    for (int i = 0; i < edge_angles.n_rows; i++)
        // want strictly positive answers
        edge_angles(i) = std::fabs(std::remainder(
                                       edge_angles(i), datum::pi / 2));

    // Remove duplicate angles
    edge_angles = unique(edge_angles);

    // Test each angle to find bounding box with smallest area
    // rot_angle, area, width, height
    double best_angle = 0;
    double best_area = DBL_MAX;
    double best_width = 0;
    double best_height = 0;

    for (int i = 0; i < edge_angles.n_rows; i++) {
        // Create rotation matrix to shift points to baseline
        mat R = {
            {
                std::cos(edge_angles(i)),
                std::cos(edge_angles(i) - datum::pi / 2)
            },
            {
                std::cos(edge_angles(i) + datum::pi / 2),
                std::cos(edge_angles(i))
            }
        };

        // Apply this rotation to convex hull points
        mat rot_points = R * hull_points_2d.t(); // 2 x 2 * 2 x n = 2 x n

        // Find min/max x,y points
        double min_x = rot_points.row(0).min();
        double max_x = rot_points.row(0).max();
        double min_y = rot_points.row(1).min();
        double max_y = rot_points.row(1).max();

        // Calculate height/width/area of this bounding rectangle
        double width = max_x - min_x;
        double height = max_y - min_y;
        double area = width * height;

        // Store the smallest rect found first
        // (a simple convex hull might have 2 answers with same area)
        if (area < best_area) {
            best_angle = edge_angles(i);
            best_area = area;
            best_width = width;
            best_height = height;
        }
    }

    // rot_angle, width, height
    return std::make_tuple(best_angle, best_width, best_height);
}

// test
int main() {
    mat a = {
        {0.1006,   0.4466},
        {0.3247,   0.8609},
        {0.6200,   0.7578},
        {0.9327,   0.2649},
        {0.9609,   0.2063},
        {0.4614,   0.0161},
        {0.1569,   0.0583},
        {0.1006,   0.4466}
    };
    std::tuple<double, double, double> b = minBoundingRect(a);
    cout << std::get<0>(b) << "\n";
    cout << std::get<1>(b) << "\n";
    cout << std::get<2>(b) << "\n";
    return 0;
}