#include <iostream>
#include "graph.hpp"

using Eigen::MatrixX2d;
using Eigen::MatrixXd;

std::pair<Graph, Sizes> load_graph(std::string path)
{
    Graph graph = Graph();
    Sizes sizes = Sizes();

    std::ifstream graph_file(path);
    std::string line;
    int line_number = 0;

    while (std::getline(graph_file, line))
    {
        if (line_number > 0)
        {
            std::stringstream linestream(line);
            std::string name, data;
            int size;

            linestream >> name >> size;
            sizes[name] = size;
            Vert v = {name, 0};

            while (linestream >> data)
            {
                graph[v].insert({data, 0});
            }
        }
        line_number += 1;
    }

    return std::make_pair(graph, sizes);
}

std::string edg(std::string s1, std::string s2)
{
    return s1 + " " + s2;
}

Graph reshape_graph(Graph graph, Sizes sizes, std::mt19937 &rng)
{
    Graph new_graph = Graph();
    std::set<std::string> done = {};

    for (auto const &v_us : graph)
    {
        Vert v = v_us.first;
        for (auto const &u : v_us.second)
            if (done.find(edg(v.first, u.first)) == done.end())
            {
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

    for (auto const &v_us : graph)
    {
        Vert v = v_us.first;
        if (sizes[v.first] > 1)
            for (int k = 1; k <= sizes[v.first]; k++)
            {
                Vert u1 = {v.first, k};
                Vert u2 = {v.first, (k % sizes[v.first]) + 1};
                new_graph[u1].insert(u2);
                new_graph[u2].insert(u1);
            }
    }

    return new_graph;
}

EdgeWeights calc_weights(Graph graph)
{
    EdgeWeights ws = {};

    for (auto const &v_vs : graph)
    {
        Vert v = v_vs.first;
        for (auto const &u : graph[v])
        {
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
            ws[{u, v}] = vs_or_us.size() - vs_and_us.size();
        }
    }
    return ws;
}

// Floyd-Warshall algorithm
MatrixXd calc_dists(Graph graph, EdgeWeights weights)
{
    int n = graph.size();
    MatrixXd dists = MatrixXd::Zero(n, n);
    Vert v, u, t;
    int i, j, k;
    Edge e;

    i = 0;
    for (auto const &v_vs : graph)
    {
        v = v_vs.first;
        j = 0;
        for (auto const &u_us : graph)
        {
            u = u_us.first;
            e = {v, u};
            if (v != u)
            {
                if (weights.find(e) == weights.end())
                {
                    dists(i, j) = std::numeric_limits<double>::max();
                }
                else
                {
                    dists(i, j) = weights[e];
                }
            }
            j++;
        }
        i++;
    }

    k = 0;
    for (auto const &v_vs : graph)
    {
        v = v_vs.first;
        i = 0;
        for (auto const &u_us : graph)
        {
            u = u_us.first;
            j = 0;
            for (auto const &t_ts : graph)
            {
                t = t_ts.first;
                if (dists(i, j) > dists(i, k) + dists(k, j))
                {
                    dists(i, j) = dists(i, k) + dists(k, j);
                }
                j++;
            }
            i++;
        }
        k++;
    }
    return dists;
}

void save_embedding(MatrixX2d data, Graph graph, std::string fname)
{
    std::ofstream emb_file(fname);
    emb_file << data.rows() << "\n";
    int i = 0;
    for (auto const &v_vs : graph)
    {
        emb_file << v_vs.first.first << " " << data(i, 0) << " " << data(i, 1);
        emb_file << " 1 0\n";
        i++;
    }
}

// Debuging tools

void print_vert(Vert v)
{
    std::cout << v.first << "_" << v.second << " ";
}

void print_graph(Graph graph)
{
    for (auto const &v_us : graph)
    {
        print_vert(v_us.first);
        std::cout << ": ";
        for (auto const &u : v_us.second)
        {
            print_vert(u);
        }
        std::cout << "\n";
    }
}

void print_sizes(Sizes sizes)
{
    for (auto const &v_i : sizes)
        std::cout << v_i.first << " : " << v_i.second << "\n";
}

void print_weights(EdgeWeights weights)
{
    for (auto const &e_i : weights)
    {
        std::cout << "(";
        print_vert(e_i.first.first);
        std::cout << ", ";
        print_vert(e_i.first.second);
        std::cout << ") " << e_i.second << "\n";
    }
}
