#include <iostream>
#include <list>
#include <fstream>
#include <sstream>
#include <set>
#include <random>
#include <queue>
#include <ctime>
#include <algorithm>
#include <unordered_set>
#include <unordered_map>
#include <functional>
#include "min_bounding_rect.hpp"
#include "qhull_2d.hpp"
#include "sammon.hpp"

#define MAX_IT 10
#define GRAV_IT 10
#define GRAV_POINTS_PER_EDGE 6

#define Sizes       std::map<std::string, int>
#define Vert        std::pair<std::string, int>
#define Graph       std::map<Vert, std::set<Vert> >
#define Edge        std::pair<Vert, Vert>
#define EdgeWeights std::map<Edge, int>

using namespace arma;

std::random_device rd;
std::mt19937 rng(rd());


// Debugging help

void print_vert(Vert v) {
    std::cout << v.first << "_" << v.second << " ";
}

void print_graph(Graph graph) {
    for (auto const& v_us : graph) {
        print_vert(v_us.first);
        std::cout << ": ";
        for (auto const& u : v_us.second) {
            print_vert(u);
        }
        std::cout << "\n";
    }
}

void print_sizes(Sizes sizes) {
    for (auto const& v_i : sizes)
        std::cout << v_i.first << " : " << v_i.second << "\n";
}

void print_weights(EdgeWeights weights) {
    for (auto const& e_i : weights) {
        std::cout << "(";
        print_vert(e_i.first.first);
        std::cout << ", ";
        print_vert(e_i.first.second);
        std::cout << ") " << e_i.second << "\n";
    }
}

// Actual stuff

mat pull_points(mat points, mat grav_points, vec mass, double g) {
    mat dists = euclid(points, grav_points) + 1;
    mat dists2 = pow(dists, 2);
    mat force = mass.t() * g / dists2.each_row();
    cube diffs = cube(grav_points.n_rows, points.n_rows, 2);
    for (int i = 0; i < grav_points.n_rows; i++)
        for (int j = 0; j < points.n_rows; j++)
            diffs.tube(i, j) = grav_points.row(i) - points.row(j);
    mat lengths = sqrt(sum(pow(diffs, 2), 2));
    lengths.replace(0, 1);
    diffs.each_slice() /= lengths;
    mat movements = sum(diffs.each_slice() % force.t());
    return points + movements;
}

mat make_grav_points(int points_per_edge, vec xlim, vec ylim) {
    vec lx = linspace(xlim(0), xlim(1), points_per_edge);
    vec ly = linspace(ylim(0), ylim(1), points_per_edge);

    mat res = mat(0, 2);

    mat pt1 = join_horiz(lx, ones(lx.size()) * ylim[0]);
    res = join_vert(res, pt1);

    mat pt2 = join_horiz(lx, ones(lx.size()) * ylim[1]);
    res = join_vert(res, pt2);

    mat pt3 = join_horiz(ones(ly.size()) * ylim[0], ly);
    res = join_vert(res, pt3.rows(1, points_per_edge - 2));

    mat pt4 = join_horiz(ones(ly.size()) * ylim[1], ly);
    res = join_vert(res, pt4.rows(1, points_per_edge - 2));

    return res;
}

std::pair<Graph, Sizes> load_graph(std::string path) {
    Graph graph = Graph();
    Sizes sizes = Sizes();

    std::ifstream graph_file(path);
    std::string line;
    int line_number = 0;

    while (std::getline(graph_file, line)) {
        if (line_number > 0) {
            std::stringstream linestream(line);
            std::string name, data;
            int size;

            linestream >> name >> size;
            sizes[name] = size;
            Vert v = {name, 0};

            while (linestream >> data)
                graph[v].insert({data, 0});
        }
        line_number += 1;
    }

    return std::make_pair(graph, sizes);
}

std::string edg(std::string s1, std::string s2) {
    return s1 + " " + s2;
}

Graph reshape_graph(Graph graph, Sizes sizes) {
    Graph new_graph = Graph();
    std::set<std::string> done = {};

    for (auto const& v_us : graph) {
        Vert v = v_us.first;
        for (auto const& u : v_us.second)
            if (done.find(edg(v.first, u.first)) == done.end()) {
                std::uniform_int_distribution<int> univ(1, sizes[v.first]);
                std::uniform_int_distribution<int> uniu(1, sizes[u.first]);
                Vert v_ = {v.first, univ(rng)};
                Vert u_ = {u.first, uniu(rng)};
                new_graph[v_].insert(u_);
                new_graph[u_].insert(v_);
                done.insert(edg(v.first, u.first));
                done.insert(edg(u.first, v.first));
            }
    }

    for (auto const& v_us : graph) {
        Vert v = v_us.first;
        if (sizes[v.first] > 1)
            for (int k = 1; k <= sizes[v.first]; k++) {
                Vert u1 = {v.first, k};
                Vert u2 = {v.first, (k % sizes[v.first]) + 1};
                new_graph[u1].insert(u2);
                new_graph[u2].insert(u1);
            }
    }

    return new_graph;
}

mat scale(mat X, bool with_mean = true, bool with_std = true) {
    if (with_mean) {
        X = X.each_row() - mean(X);
        X.each_row() -= mean(X); // in case of very large values in X
    }
    if (with_std) {
        mat scale_ = stddev(X, 1);
        scale_.replace(0, 1);

        X = X.each_row() / scale_;
        if (with_mean)
            X.each_row() -= mean(X);
    }
    return X;
}

mat squeeze(mat data, vec lxy = {0, 0}, vec hxy = {1, 1}) {
    mat mins = min(data);
    mat maxs = max(data) - mins;
    mat new_data = data.each_row() - mins;
    new_data.each_row() /= maxs;
    new_data.each_row() %= hxy.t() - lxy.t();
    new_data.each_row() += lxy.t();
    return new_data;
}

EdgeWeights calc_weights(Graph graph, Sizes sizes) {
    EdgeWeights ws = {};

    for (auto const& v_vs : graph) {
        Vert v = v_vs.first;
        for (auto const& u : graph[v]) {
            std::set<Vert> vs = v_vs.second;
            std::set<Vert> us = graph[u];
            std::set<Vert> vs_or_us;
            std::set<Vert> vs_and_us;
            std::set_union(
                vs.begin(), vs.end(), us.begin(), us.end(),
                std::inserter(vs_or_us, vs_or_us.begin()));
            std::set_intersection(
                vs.begin(), vs.end(), us.begin(), us.end(),
                std::inserter(vs_and_us, vs_and_us.begin()));
            ws[ {u, v}] = vs_or_us.size() - vs_and_us.size();
        }
    }
    return ws;
}

// Floyd-Warshall algorithm
mat calc_dists(Graph graph, EdgeWeights weights) {
    int n = graph.size();
    mat dists = zeros<mat>(n, n);
    Vert v, u, t;
    int i, j, k;
    Edge e;

    i = 0;
    for (auto const& v_vs : graph) {
        v = v_vs.first;
        j = 0;
        for (auto const& u_us : graph) {
            u = u_us.first;
            e = {v, u};
            if (v != u) {
                if (weights.find(e) == weights.end())
                    dists(i, j) = datum::inf;
                else
                    dists(i, j) = weights[e];
            }
            j++;
        }
        i++;
    }

    k = 0;
    for (auto const& v_vs : graph) {
        v = v_vs.first;
        i = 0;
        for (auto const& u_us : graph) {
            u = u_us.first;
            j = 0;
            for (auto const& t_ts : graph) {
                t = t_ts.first;
                if (dists(i, j) > dists(i, k) + dists(k, j))
                    dists(i, j) = dists(i, k) + dists(k, j);
                j++;
            }
            i++;
        }
        k++;
    }
    return dists;
}

void save_embedding(mat data, Graph graph, std::string fname) {
    std::ofstream emb_file(fname);
    emb_file << data.n_rows << "\n";
    int i = 0;
    for (auto const& v_vs : graph) {
        emb_file << v_vs.first.first << " " << data(i, 0) << " " << data(i, 1);
        emb_file << " 1 0\n";
        i++;
    }
}

int main(int argc, char** argv) {
    time_t t0 = clock();

    std::cout << (double) (clock() - t0) / CLOCKS_PER_SEC << "\n";
    t0 = clock();

    if (argc < 2) {
        std::cerr << "Input file not provided.\n";
        return 1;
    }

    std::string input_path = argv[1];
    std::string output_path;

    if (argc > 2)
        output_path = argv[2];
    else
        output_path = input_path + "_emb";

    std::cout << (double) (clock() - t0) / CLOCKS_PER_SEC << "\n";
    t0 = clock();

    std::pair<Graph, Sizes> gs = load_graph(input_path);
    Sizes sizes = gs.second;

    std::cout << (double) (clock() - t0) / CLOCKS_PER_SEC << "\n";
    t0 = clock();

    Graph graph = reshape_graph(gs.first, sizes);

    std::cout << (double) (clock() - t0) / CLOCKS_PER_SEC << "\n";
    t0 = clock();

    EdgeWeights weights = calc_weights(graph, sizes);

    std::cout << (double) (clock() - t0) / CLOCKS_PER_SEC << "\n";
    t0 = clock();

    mat dists = calc_dists(graph, weights);

    std::cout << (double) (clock() - t0) / CLOCKS_PER_SEC << "\n";
    t0 = clock();

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
