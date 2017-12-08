#include <iostream>
#include <list>
#include <fstream>
#include <sstream>
#include <set>
#include <random>
#include "min_bounding_rect.hpp"
#include "qhull_2d.hpp"
#include "sammon.hpp"

#define MAX_IT 10
#define MAKE_A_PLOT false
#define GRAV_POINTS_PER_EDGE 6

#define Sizes       std::map<std::string, int>
#define Graph       std::map<Vert, std::set<Vert> >
#define EdgeWeights std::map<std::pair<Vert, Vert>, int>

using namespace arma;

// from sklearn.preprocessing import scale
// from scipy.spatial import Voronoi
// from heapq import heappop, heappush

std::random_device rd;
std::mt19937 rng(rd());

struct Vert {
    std::string id;
    int sub_id;

    bool operator<(const Vert& rhs) const {
        return std::tie(id, sub_id) < std::tie(rhs.id, rhs.sub_id);
    }

    bool operator==(const Vert& rhs) const {
        return id == rhs.id && sub_id == rhs.sub_id;
    }
};

// struct Graph {
//     std::map<Vert, std::list<Vert> > graph;

//     std::list<Vert> &operator[](const Vert v) {
//         return graph[v];
//     }
// };

mat pull_points(mat points, mat grav_points, vec mass, double g) {
    mat dists = euclid(points, grav_points) + 1;
    mat dists2 = pow(dists, 2);
    mat force = mass * g / dists2.each_row();

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

mat make_grav_points(int points_per_edge, double xliml, double xlimh,
                     double yliml, double ylimh) {
    vec lx = linspace(xliml, xlimh, points_per_edge);
    vec ly = linspace(yliml, ylimh, points_per_edge);

    mat res = mat(0, 2);

    mat pt1 = join_horiz(lx, ones(lx.size()) * yliml);
    res = join_vert(res, pt1);

    mat pt2 = join_horiz(lx, ones(lx.size()) * ylimh);
    res = join_vert(res, pt2);

    mat pt3 = join_horiz(ones(ly.size()) * yliml, ly);
    res = join_vert(res, pt3.rows(1, points_per_edge - 2));

    mat pt4 = join_horiz(ones(ly.size()) * ylimh, ly);
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
            if (done.find(edg(v.id, u.id)) != done.end()) {
                std::uniform_int_distribution<int> univ(1, sizes[v.id]);
                std::uniform_int_distribution<int> uniu(1, sizes[u.id]);
                Vert v_ = {v.id, univ(rng)};
                Vert u_ = {u.id, uniu(rng)};
                new_graph[v_].insert(u_);
                new_graph[u_].insert(v_);
                done.insert(edg(v.id, u.id));
                done.insert(edg(u.id, v.id));
            }
    }

    for (auto const& v_us : graph) {
        Vert v = v_us.first;
        if (sizes[v.id] > 1)
            for (int k = 1; k <= sizes[v.id]; k++) {
                Vert u1 = {v.id, k};
                Vert u2 = {v.id, (k % sizes[v.id]) + 1};
                new_graph[u1].insert(u2);
                new_graph[u2].insert(u1);
            }
    }

    return new_graph;
}

mat squeeze(mat data, vec lxy = {0, 0}, vec hxy = {1, 1}) {
    mat mins = min(data);
    mat maxs = max(data) - mins;
    mat new_data = data.each_row() - mins;
    new_data.each_row() /= maxs;
    new_data.each_row() %= hxy - lxy;
    new_data.each_row() += lxy;
    return new_data;
}

EdgeWeights calc_weights(Graph graph, Sizes sizes) {
    EdgeWeights ws = {};

    for (auto const& v_vs : graph) {
        Vert v = v_vs.first;
        for (auto const& u_us : graph) {
            Vert u = u_us.first;
            if (!(v == u)) {
                std::set<Vert> vs = v_vs.second;
                std::set<Vert> us = u_us.second;
                std::set<Vert> vs_or_us;
                std::set<Vert> vs_and_us;
                std::set_union(
                    vs.begin(), vs.end(), us.begin(), us.end(),
                    std::inserter(vs_or_us, vs_or_us.begin()));
                std::set_intersection(
                    vs.begin(), vs.end(), us.begin(), us.end(),
                    std::inserter(vs_and_us, vs_and_us.begin()));
                ws[ {u, v}] = vs_and_us.size() - vs_and_us.size();
            }
        }
    }
    return ws;
}

int main(int argc, char** argv) {
    // for (int i = 0; i < 10; i++) {
    //     std::uniform_int_distribution<int> uni(100*i, 101*i);
    //     cout << uni(rng) << "\n";
    //     cout << uni(rng) << "\n";
    //     cout << uni(rng) << "\n";
    // }
    EdgeWeights ws = {};
    Graph g = Graph();
    Vert v = {"1", 2};
    Vert u = {"1", 2};
    ws[ {v, u}] = 1;
    std::pair<Vert, int> d = {v, 1};
    g[v].insert({"2", 5});
    g[u].insert(u);
    cout << g[v].size();
    cout << (v == Vert({"1", 3}));
    return 0;
}
