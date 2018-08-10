#ifndef _GENETIC_H
#define _GENETIC_H

struct map;
struct poi;
struct pattern;
struct data;
struct possible_positions;
struct creature;

void crate_random_creature(struct creature* monster, struct possible_positions* P, int nzones, int nsfw);
void crossover(struct creature* parent1, struct creature* parent2, struct creature* child1, struct creature* child2, int nzones, int nsfw);
void mutation(struct creature* monster, struct possible_positions* P, int nzones, int nsfw, int mut);
void bfs(struct map* M, int** res, int sx, int sy);
void addpath(int** bfs_results, struct map* printmap, int sx, int sy);
int  evaluate(struct creature* monster, struct data* D, int print);
//void path_repair(struct map* M)
void print_mst(struct creature* monster, struct data* D);
struct creature* genetic(struct data* D, int pop_size, int mut_prom, int time_limit);

#endif
