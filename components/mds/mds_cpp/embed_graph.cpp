#include <iostream>
#include <list>
#include <fstream>
#include <sstream>
#include "min_bounding_rect.hpp"
#include "qhull_2d.hpp"
#include "sammon.hpp"

#define MAX_IT 10
#define MAKE_A_PLOT false
#define GRAV_POINTS_PER_EDGE 6

#define Sizes std::map<std::string, double>

using namespace arma;

// from sklearn.preprocessing import scale
// from scipy.spatial import Voronoi
// from heapq import heappop, heappush


struct Vert {
    std::string id;
    int sub_id;

    bool operator<(const Vert& rhs) const {
        return std::tie(id, sub_id) < std::tie(rhs.id, rhs.sub_id);
    }
};

struct Graph {
    std::map<Vert, std::list<Vert> > graph;

    std::list<Vert> &operator[](const Vert v) {
        return graph[v];
    }
};


bool same_vert(Vert a, Vert b) {
    return a.id == b.id;
}


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

    while(std::getline(graph_file, line)) {
        if (line_number > 0) {
            std::stringstream linestream(line);
            std::string name, data;
            double size;

            linestream >> name >> size;
            sizes[name] = size;
            Vert v = {name, 0};

            while(std::getline(linestream, data, ' ')) {
                if (data.length() > 0)
                    graph[v].push_back(Vert({data, 0}));
            }
        }
        line_number += 1;
    }

    return std::make_pair(graph, sizes);
}

int main(int argc, char** argv)
{
    Graph g = Graph();
    Vert v = {"1", 2};
    g[v].push_back(v);
    cout << (g.graph.size());
    return 0;
}
