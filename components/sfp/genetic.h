#include "structures.h"

const int dn = 8;
int dx[dn] = { -1, -1, -1, 0, 0, 1, 1, 1};
int dy[dn] = { -1, 0, 1, -1, 1, -1, 0, 1};

void bfs(struct map* M, int** res, int sx, int sy)
{
    int qx[M->n * M->m];
    int qy[M->n * M->m];
    int head = 0, tail = 0;
    
    for (int i = 0; i < M->n; i++)
        for (int j = 0; j < M->m; j++)
            res[i][j] = oo;
    res[sx][sy] = 0;
    
    qx[head] = sx;
    qy[head] = sy;
    head++;
    
    while (head > tail)
    {
        int cx = qx[tail];
        int cy = qy[tail];
        tail++;
        
        for (int i = 0; i < dn; i++)
        {
            int nx = cx + dx[i];
            int ny = cy + dy[i];
            
            if (res[nx][ny] == oo)
            {
                res[nx][ny] = res[cx][cy] + 1;
                if (M->T[nx][ny] != WALL)
                {
                    qx[head] = nx;
                    qy[head] = ny;
                    head++;
                }
            }
        }
    }
}

struct creature
{
    struct poi** P;
};

struct possible_positions
{
    int** N;
    struct poi*** PP;
};

void crossover(struct creature* parent1, struct creature* parent2, struct creature* child, int nzones, int nsfw)
{
    for (int i = 0; i < nzones; i++)
        for (int j = 0; j < nsfw; j++)
            if (rand() % 2 == 0)
                child->P[i][j] = parent1->P[i][j];
            else
                child->P[i][j] = parent2->P[i][j];
}

void create_possible_positions(struct data* D, struct possible_positions* P)
{
    P->N  = (int**)malloc(sizeof(int*) * D->nzones);
    P->PP = (struct poi***)malloc(sizeof(struct poi**) * D->nzones);
    for (int z = 0; z < D->nzones; z++)
    {
        P->N[z]  = (int*)malloc(sizeof(int) * D->nsfw);
        P->PP[z] = (struct poi**)malloc(sizeof(struct poi*) * D->nsfw);
        
        for (int o = 0; o < D->nsfw; o++)
        {
            P->N[z][o] = 0;
            P->PP[z][o] = (struct poi*)malloc(sizeof(struct poi) * D->zone[z].n * D->zone[z].m);
            
            for (int i = 0; i < D->zone[z].n; i++)
                for (int j = 0; j < D->zone[z].m; j++)
                    if (check_placement(&D->zone[z], &D->objects[z][o], i, j) == 0)
                    {
                        P->PP[z][o][P->N[z][o]].x = i;
                        P->PP[z][o][P->N[z][o]].y = j;
                        P->N[z][o]++;
                    }
        }
    }
}

void crate_random_creature(struct creature* monster, struct possible_positions* P, int nzones, int nsfw)
{
    for (int i = 0; i < nzones; i++)
        for (int j = 0; j < nsfw; j++)
            monster->P[i][j] = P->PP[i][j][ rand() % P->N[i][j] ];
}

void mutation(struct creature* monster, struct possible_positions* P, int nzones, int nsfw)
{
    int rzone = rand() % nzones;
    int rsfw  = rand() % nsfw;
    
    monster->P[rzone][rsfw] = P->PP[rzone][rsfw][ rand() % P->N[rzone][rsfw] ];
}

int evaluate(struct creature* monster, struct data* D)
{
    int obj2poi[D->nzones][D->nsfw][D->npois1 + D->npois2];
    int obj2obj[D->nzones][D->nsfw][D->nsfw];
    
    for (int i = 0; i < D->nzones; i++)
    {
        int **bfs_results;
        struct map temp_map;
        
        bfs_results = (int**)malloc(sizeof(int*) * D->zone[i].n);
        for (int j = 0; j < D->zone[i].n; j++)
            bfs_results[j] = (int*)malloc(sizeof(int) * D->zone[i].m);
        
        copy_map(&D->zone[i], &temp_map);
        for (int j = 0; j < D->nsfw; j++)
        {
            if (check_placement(&temp_map, &D->objects[i][j], monster->P[i][j].x, monster->P[i][j].y) != 0)
                return oo;
            place(&temp_map, &D->objects[i][j], monster->P[i][j].x, monster->P[i][j].y);
        }
        
        for (int j = 0; j < D->nsfw; j++)
        {
            bfs(&D->zone[i], bfs_results, monster->P[i][j].x, monster->P[i][j].y);
            
            for (int k = 0; k < D->npois1 + D->npois2; k++)
            {
                obj2poi[i][j][k] = bfs_results[ D->pois[i][k].x ][ D->pois[i][k].y ];
                if (obj2poi[i][j][k] == oo) return oo;
            }
            
            for (int k = 0; k < D->nsfw; k++)
            {
                obj2obj[i][j][k] = bfs_results[ monster->P[i][k].x ][ monster->P[i][k].y ];
                if (obj2obj[i][j][k] == oo) return oo;
            }
        }        
        
        destroy_map(&temp_map);
        
        for (int j = 0; j < D->zone[i].n; j++)
            free(bfs_results[j]);
        free(bfs_results);
    }
    
    int result = 0;
    
    for (int i = 0; i < D->nzones; i++)
        for (int j = i+1; j < D->nzones; j++)
            for (int k = 0; k < D->nsfw; k++)
            {
                for (int l = 0; l < D->npois1 + D->npois2; l++)
                    result += (obj2poi[i][k][l] - obj2poi[j][k][l]) * (obj2poi[i][k][l] - obj2poi[j][k][l]);
                for (int l = 0; l < D->nsfw; l++)
                    result += (obj2obj[i][k][l] - obj2obj[j][k][l]) * (obj2obj[i][k][l] - obj2obj[j][k][l]);
            }
    
    return result;
}

void copy_crature(struct creature* src, struct creature* dest, int nzones, int nsfw)
{
    for (int i = 0; i < nzones; i++)
        for (int j = 0; j < nsfw; j++)
            dest->P[i][j] = src->P[i][j];
}

struct creature* genetic(struct data* D)
{
    struct creature bst[best_size];
    struct creature popul[pop_size];
    int values[pop_size];
    struct possible_positions possible;
    struct creature* best_creature;
    int best_value = oo;
    
    create_possible_positions(D, &possible);
    
    best_creature = (struct creature*)malloc(sizeof(struct creature));
    best_creature->P = (struct poi**)malloc(sizeof(struct poi*) * D->nzones);
    for (int j = 0; j < D->nzones; j++)
        best_creature->P[j] = (struct poi*)malloc(sizeof(struct poi) * D->nsfw);
    
    for (int i = 0; i < best_size; i++)
    {
        bst[i].P = (struct poi**)malloc(sizeof(struct poi*) * D->nzones);
        for (int j = 0; j < D->nzones; j++)
            bst[i].P[j] = (struct poi*)malloc(sizeof(struct poi) * D->nsfw);
    }
    
    for (int i = 0; i < pop_size; i++)
    {
        popul[i].P = (struct poi**)malloc(sizeof(struct poi*) * D->nzones);
        for (int j = 0; j < D->nzones; j++)
            popul[i].P[j] = (struct poi*)malloc(sizeof(struct poi) * D->nsfw);
    }
    
    for (int i = 0; i < pop_size; i++)
        crate_random_creature(&popul[i], &possible, D->nzones, D->nsfw);
    
    for (int iter = 0; iter < n_iter; iter++)
    {
        for (int i = 0; i < pop_size; i++)
            values[i] = evaluate(&popul[i], D);
        
        for (int i = 0; i < best_size; i++)
            for (int j = pop_size-1; j > 0; j--)
                if (values[j-1] > values[j])
                {
                    int t = values[j-1];
                    values[j-1] = values[j];
                    values[j] = t;
                    
                    struct creature tmp = popul[j-1];
                    popul[j-1] = popul[j];
                    popul[j] = tmp;
                }
        
        if (values[0] < best_value)
        {
            best_value = values[0];
            copy_crature(&popul[0], best_creature, D->nzones, D->nsfw);
        }
        
        for (int i = 0; i < best_size; i++)
            copy_crature(&popul[i], &bst[i], D->nzones, D->nsfw);
        
        int c = 0;
        for (int i = 0; i < best_size; i++)
            for (int j = i+1; j < best_size; j++)
                if (c < pop_size)
                    crossover(&bst[i], &bst[j], &popul[c++], D->nzones, D->nsfw);
        
        for (int i = 0; i < pop_size; i++)
            if (rand()%1000 < mut_prom)
                mutation(&popul[i], &possible, D->nzones, D->nsfw);
        
    }
    
    
    for (int i = 0; i < best_size; i++)
    {
        for (int j = 0; j < D->nzones; j++)
            free(bst[i].P[j]);
        free(bst[i].P);
    }
    
    for (int i = 0; i < pop_size; i++)
    {
        for (int j = 0; j < D->nzones; j++)
            free(popul[i].P[j]);
        free(popul[i].P);
    }
    
    return best_creature;
}
