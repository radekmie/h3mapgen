#ifndef graph_hpp
#define graph_hpp

#include <set>
#include <map>
#include <random>
#include <fstream>
#include <sstream>
#include <Eigen/Dense>

#define Sizes std::map<std::string, int>
#define Vert std::pair<std::string, int>
#define Graph std::map<Vert, std::set<Vert>>
#define Edge std::pair<Vert, Vert>
#define EdgeWeights std::map<Edge, int>

void print_vert(Vert v);

void print_graph(Graph graph);

void print_sizes(Sizes sizes);

void print_weights(EdgeWeights weights);

std::pair<Graph, Sizes> load_graph(std::string path);

std::string edg(std::string s1, std::string s2);

Graph reshape_graph(Graph graph, Sizes sizes);

EdgeWeights calc_weights(Graph graph);

Eigen::MatrixXd calc_dists(Graph graph, EdgeWeights weights);

void save_embedding(Eigen::MatrixX2d data, Graph graph, std::string fname);

#endif