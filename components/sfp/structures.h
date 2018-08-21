#ifndef _STRUCTURES_H
#define _STRUCTURES_H

struct map
{
    char** T; // T[n][m+1]
    int n, m;
};

void init_map(struct map* M);
void alloc_map(struct map* M, int n, int m);
void destroy_map(struct map* M);
void read_map(struct map* M);
void print_map(struct map* M);
void copy_map(struct map* src, struct map* dest);
int  check_map(struct map* M);

struct poi
{
    int x, y;
};

void init_poi(struct poi* P);
void read_poi(struct poi* P);
void print_poi(struct poi* P);
//int is_on_list(struct poi* pois, int n, int x, int y);

struct pattern
{
    struct map M;
    struct poi P;
};

void init_pattern(struct pattern* P);
void destroy_pattern(struct pattern* P);
void read_pattern(struct pattern* T);
void print_pattern(struct pattern* T);
int  check_pattern(struct pattern* T);

int  check_placement(struct map* M, struct pattern* P, int x, int y);
void place(struct map* M, struct pattern* P, int x, int y);

struct data
{
    int nzones;
    int npois1;
    int npois2;
    int nsfw;

    struct map*      zone;    // zone[nzones]
    struct poi**     pois;    // pois[nzones][npois1+npois2]
    struct pattern** objects; // objects[nzones][nsfw]
};

void init_data(struct data* D);
void alloc_data(struct data* D, int nzones, int npois1, int npois2, int nsfw);
void destroy_data(struct data*D);
void read_data(struct data* D);
void print_data(struct data* D);
int  check_data(struct data* D);

struct possible_positions
{
    int** N;          // N[D->nzones][D->nsfw]
    struct poi*** PP; // PP[D->nzones][D->nsfw][N]
};

void create_possible_positions(struct data* D, struct possible_positions* P);

void init_findunion(int* fu, int size);
int  find_findunion(int* fu, int i);
int  union_findunion(int* fu, int i, int j);

struct creature
{
    struct poi** P; // P[nzones][nsfw]
};

void init_creature(struct creature* C);
void alloc_creature(struct creature* C, int nzones, int nsfw);
void destroy_creature(struct creature* C, int nzones);
void copy_creature(struct creature* src, struct creature* dest, int nzones, int nsfw);
int  compare_creature(struct creature* one, struct creature* two, int nzones, int nsfw);

#endif
