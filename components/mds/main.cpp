#include <iostream>

#include "min_bounding_rect.hpp"
#include "qhull_2d.hpp"
#include "sammon.hpp"
#include "graph.hpp"
#include "postproc.hpp"

using Eigen::MatrixX2d;
using Eigen::MatrixXd;

#define MAX_IT 10
#define GRAV_IT 10
#define GRAV_POINTS_PER_EDGE 6

int main(int argc, char **argv)
{
    if (argc < 2)
    {
        std::cerr << "Input file not provided.\n";
        return 1;
    }

    std::string input_path = argv[1];
    std::string output_path;

    if (argc > 2)
        output_path = argv[2] + std::string(".txt");
    else
        output_path = input_path + "_emb.txt";

    std::mt19937 rng;

    if (argc == 4) {
        std::seed_seq seed{std::atoi(argv[3])};
        rng = std::mt19937(seed);
    } else {
        std::random_device rd;
        rng = std::mt19937(rd());
    }

    std::pair<Graph, Sizes> gs = load_graph(input_path);
    Sizes sizes = gs.second;
    Graph graph = reshape_graph(gs.first, sizes, rng);
    EdgeWeights weights = calc_weights(graph);
    MatrixXd dists = calc_dists(graph, weights);

    auto embed = [dists]() {
        std::pair<MatrixX2d, double> emb = sammon(dists, 0);
        MatrixX2d data_trans_scaled = squeeze(
            emb.first, {-2.5, -2.5}, {2.5, 2.5});
        data_trans_scaled = scale(data_trans_scaled);
        MatrixX2d ch = qhull2D(data_trans_scaled);

        std::tuple<double, double, double> rect = minBoundingRect(ch);
        double theta = std::get<0>(rect);
        double width = std::get<1>(rect);
        double height = std::get<2>(rect);

        Eigen::Matrix2d R;
        R << cos(theta), -sin(theta), sin(theta), cos(theta);

        data_trans_scaled = data_trans_scaled * R;
        data_trans_scaled.array().col(0) *= height / width;
        data_trans_scaled = squeeze(
            data_trans_scaled, {-2.2, -2.2}, {2.2, 2.2});

        // "gravity"
        MatrixX2d grav_points = make_grav_points(
            GRAV_POINTS_PER_EDGE, {-2.2, 2.2}, {-2.2, 2.2});

        for (int i = 0; i < GRAV_IT; i++)
        {
            Eigen::VectorXd mass =
                euclid(grav_points, data_trans_scaled).rowwise().minCoeff();
            data_trans_scaled = pull_points(
                data_trans_scaled, grav_points, mass, 0.5);
        }

        return std::make_pair(data_trans_scaled, emb.second);
    };

    std::pair<MatrixX2d, double> sol;
    MatrixX2d best_sol;
    double best_loss = std::numeric_limits<double>::max();
    std::cout << "Testing " << MAX_IT << " embeddings...\n";

    for (int i = 0; i < MAX_IT; i++)
    {
        sol = embed();
        double E = sol.second;
        std::cout << E << "\n";
        if (E < best_loss)
        {
            best_loss = E;
            best_sol = sol.first;
        }
    }

    std::cout << "Best loss: " << best_loss << "\n";
    save_embedding(best_sol, graph, output_path);
    return 0;
}
