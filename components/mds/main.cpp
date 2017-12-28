#include <iostream>

#include "min_bounding_rect.hpp"
#include "qhull_2d.hpp"
#include "sammon.hpp"
#include "graph.hpp"
#include "postproc.hpp"

#define MAX_IT 10
#define GRAV_IT 10
#define GRAV_POINTS_PER_EDGE 6

using namespace arma;


int main(int argc, char** argv) {
    arma_rng::set_seed_random();

    if (argc < 2) {
        std::cerr << "Input file not provided.\n";
        return 1;
    }

    std::string input_path = argv[1];
    std::string output_path;

    if (argc > 2)
        output_path = argv[2];
    else
        output_path = input_path + "_emb.txt";

    std::pair<Graph, Sizes> gs = load_graph(input_path);
    Sizes sizes = gs.second;
    Graph graph = reshape_graph(gs.first, sizes);
    EdgeWeights weights = calc_weights(graph);
    mat dists = calc_dists(graph, weights);

    auto embed = [dists]() {
        std::pair<mat, double> emb = sammon(dists, 0);
        mat data_trans_scaled = squeeze(emb.first, { -2.5, -2.5}, {2.5, 2.5});
        data_trans_scaled = scale(data_trans_scaled);
        mat ch = qhull2D(data_trans_scaled);

        std::tuple<double, double, double> rect = minBoundingRect(ch);
        double theta = std::get<0>(rect);
        double width = std::get<1>(rect);
        double height = std::get<2>(rect);

        mat R = {
            {cos(theta), -sin(theta)},
            {sin(theta),  cos(theta)}
        };

        data_trans_scaled = data_trans_scaled * R;
        data_trans_scaled.col(0) *= height / width;
        data_trans_scaled = squeeze(data_trans_scaled,
        { -2.2, -2.2}, {2.2, 2.2});

        // "gravity"
        mat grav_points = make_grav_points(GRAV_POINTS_PER_EDGE,
        { -2.2, 2.2}, { -2.2, 2.2});

        for (int i = 0; i < GRAV_IT; i++) {
            mat mass = min(euclid(grav_points, data_trans_scaled), 1);
            data_trans_scaled = pull_points(data_trans_scaled, grav_points,
                                            mass, 0.5);
        }

        return std::make_pair(data_trans_scaled, emb.second);
    };

    std::pair<mat, double> sol;
    mat best_sol;
    double best_loss = datum::inf;
    std::cout << "Testing " << MAX_IT << " embeddings...\n";

    for (int i = 0; i < MAX_IT; i++) {
        sol = embed();
        double E = sol.second;
        std::cout << E << "\n";
        if (E < best_loss) {
            best_loss = E;
            best_sol = sol.first;
        }
    }

    std::cout << "Best loss: " << best_loss << "\n";
    save_embedding(best_sol, graph, output_path);
    return 0;
}
