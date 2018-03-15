#include "structures.hpp"

#include <stdlib.h>
#include <time.h>

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

void crossover(struct creature* parent1, struct creature* parent2, struct creature* child1, struct creature* child2, int nzones, int nsfw)
{
    for (int i = 0; i < nzones; i++)
        for (int j = 0; j < nsfw; j++)
            if (rand() % 2 == 0)
            {
                child1->P[i][j] = parent1->P[i][j];
                child2->P[i][j] = parent2->P[i][j];
            }
            else
            {
                child1->P[i][j] = parent2->P[i][j];
                child2->P[i][j] = parent1->P[i][j];
            }
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
            
            if (P->N[z][o] == 0)
            {
                printf("Cannot place objects\n");
                exit(CANNOT_PLACE_OBJECT);
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

void mutation(struct creature* monster, struct possible_positions* P, int nzones, int nsfw, int mut)
{
    int rzone = rand() % nzones;
    int rsfw  = rand() % nsfw;
    
    for (int i = 0; i < nzones; i++)
        for (int j = 0; j < nsfw; j++)
            if (rand()%1000 < mut)
                monster->P[i][j] = P->PP[i][j][ rand() % P->N[i][j] ];
}

int evaluate(struct creature* monster, struct data* D, int print = 0)
{
    int obj2poi[D->nzones][D->nsfw][D->npois1 + D->npois2];
    int obj2obj[D->nzones][D->nsfw][D->nsfw];
    
    for (int i = 0; i < D->nzones; i++)
    {
        int **bfs_results;
        struct map temp_map;
        struct map print_map;
        
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
        
        if (print == 1) copy_map(&temp_map, &print_map);
        
        for (int j = 0; j < D->nsfw; j++)
        {
            bfs(&temp_map, bfs_results, monster->P[i][j].x, monster->P[i][j].y);
            
            for (int k = 0; k < D->npois1 + D->npois2; k++)
            {
                obj2poi[i][j][k] = bfs_results[ D->pois[i][k].x ][ D->pois[i][k].y ];
                if (obj2poi[i][j][k] == oo) return oo;
                
                if (print == 1)
                {
                    int cx = D->pois[i][k].x;
                    int cy = D->pois[i][k].y;
                    
                    while (bfs_results[cx][cy] != 0)
                    {
                        if (print_map.T[cx][cy] == GROUND)
                            print_map.T[cx][cy] = TRACK;
                        
                        int l = 0;
                        while (l < dn && ((print_map.T[cx+dx[l]][cy+dy[l]] != GROUND && print_map.T[cx+dx[l]][cy+dy[l]] != TRACK) || bfs_results[cx+dx[l]][cy+dy[l]] >= bfs_results[cx][cy]))
                            l++;
                        if (l == dn) break;
                        cx += dx[l];
                        cy += dy[l];
                    }
                }
            }
            
            for (int k = 0; k < D->nsfw; k++)
            {
                obj2obj[i][j][k] = bfs_results[ monster->P[i][k].x ][ monster->P[i][k].y ];
                if (obj2obj[i][j][k] == oo) return oo;
                
                if (print == 1)
                {
                    int cx = monster->P[i][k].x;
                    int cy = monster->P[i][k].y;
                    
                    while (bfs_results[cx][cy] != 0)
                    {
                        if (print_map.T[cx][cy] == GROUND)
                            print_map.T[cx][cy] = TRACK;
                        
                        int l = 0;
                        while (l < dn && ((print_map.T[cx+dx[l]][cy+dy[l]] != GROUND && print_map.T[cx+dx[l]][cy+dy[l]] != TRACK) || bfs_results[cx+dx[l]][cy+dy[l]] >= bfs_results[cx][cy]))
                            l++;
                        if (l == dn) break;
                        cx += dx[l];
                        cy += dy[l];
                    }
                }
            }
        }
        
        if (print == 1)
            map_print(&print_map);
    
        destroy_map(&temp_map);
        if (print == 1) destroy_map(&print_map);
        
        for (int j = 0; j < D->zone[i].n; j++)
            free(bfs_results[j]);
        free(bfs_results);
    }
    
    if (print == 1)
    {
        for (int i = 0; i < D->nzones; i++)
        {
            for (int j = 0; j < D->nsfw; j++)
            {
                for (int k = 0; k < D->npois1 + D->npois2; k++)
                    printf("%d ", obj2poi[i][j][k]);
                printf("\n");
            }
            printf("\n");
        }
        
        for (int i = 0; i < D->nzones; i++)
        {
            for (int j = 0; j < D->nsfw; j++)
            {
                for (int k = 0; k < D->nsfw; k++)
                    printf("%d ", obj2obj[i][j][k]);
                printf("\n");
            }
            printf("\n");
        }
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
    
    for (int i = 0; i < D->nzones; i++)
        for (int k = D->npois1; k < D->npois1+D->npois2; k++)
            for (int j = 0; j < D->nsfw-1; j++)
                for (int l = D->npois1; l < D->nsfw-1; l++)
                    if (obj2poi[i][l][k] > obj2poi[i][l+1][k])
                    {
                        int tmp = obj2poi[i][l][k];
                        obj2poi[i][l][k] = obj2poi[i][l+1][k];
                        obj2poi[i][l+1][k] = tmp;
                    }
    
    for (int i = 0; i < D->nzones; i++)
        for (int j = 0; j < D->nsfw; j++)
            for (int k = D->npois1; k < D->npois1+D->npois2; k++)
                for (int l = k+1; k < D->npois1+D->npois2; l++)
                    result += (obj2poi[i][j][k] - obj2poi[i][j][l]) * (obj2poi[i][j][k] - obj2poi[i][j][l]);
            
    
    return result;
}

void copy_crature(struct creature* src, struct creature* dest, int nzones, int nsfw)
{
    for (int i = 0; i < nzones; i++)
        for (int j = 0; j < nsfw; j++)
            dest->P[i][j] = src->P[i][j];
}

int compare_creature(struct creature* one, struct creature* two, int nzones, int nsfw)
{
    for (int i = 0; i < nzones; i++)
        for (int j = 0; j < nsfw; j++)
            if (one->P[i][j].x != two->P[i][j].x || one->P[i][j].y != two->P[i][j].y)
                return 0;
    return 1;
}

struct creature* genetic(struct data* D)
{
    int no_impr = 0;
    struct creature bst[pop_size];
    struct creature popul[pop_size];
    int values[pop_size];
    struct possible_positions possible;
    struct creature* best_creature;
    int best_value = oo;
    clock_t start = clock(), end;
    
    create_possible_positions(D, &possible);
    
    best_creature = (struct creature*)malloc(sizeof(struct creature));
    best_creature->P = (struct poi**)malloc(sizeof(struct poi*) * D->nzones);
    for (int j = 0; j < D->nzones; j++)
        best_creature->P[j] = (struct poi*)malloc(sizeof(struct poi) * D->nsfw);
    
    for (int i = 0; i < pop_size; i++)
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
    
    end = clock();

    while (((double) (end - start)) * 1000 / CLOCKS_PER_SEC < time_limit)
    {
        for (int i = 0; i < pop_size; i++)
            values[i] = evaluate(&popul[i], D);
        
        // sort in O(n^2) !
        for (int i = 0; i < pop_size-1; i++)
            for (int j = 0; j < pop_size-1; j++)
                if (values[j] > values[j+1])
                {
                    int t = values[j+1];
                    values[j+1] = values[j];
                    values[j] = t;
                    
                    struct creature tmp = popul[j+1];
                    popul[j+1] = popul[j];
                    popul[j] = tmp;
                }
        
        if (values[0] < best_value)
        {
            no_impr = 0;
            best_value = values[0];
            copy_crature(&popul[0], best_creature, D->nzones, D->nsfw);
        }
        else if (++no_impr >= 5) break;
        
        int bst_n = 1;
        int pop_n = 0;
        copy_crature(&popul[0], &bst[0], D->nzones, D->nsfw);
        
        for (int i = 1; i < pop_size; i++)
            if (compare_creature(&popul[i], &popul[i-1], D->nzones, D->nsfw) == 0)
                copy_crature(&popul[i], &bst[bst_n++], D->nzones, D->nsfw);
        
        if (bst_n == 1) break;
            
        int it1 = 0;
        int it2 = 1;
        int mut = mut_prom;
        while (pop_n < pop_size-1)
        {
            crossover(&bst[it1], &bst[it2], &popul[pop_n], &popul[pop_n+1], D->nzones, D->nsfw);
            mutation(&popul[pop_n], &possible, D->nzones, D->nsfw, mut);
            mutation(&popul[pop_n+1], &possible, D->nzones, D->nsfw, mut);
            pop_n+=2;
            
            it1++;
            if (it1 == it2)
            {
                it1 = 0;
                it2++;
            }
            if (it2 == bst_n)
            {
                mut *= 5;
                it2 = 1;
            }
        }
        copy_crature(best_creature, &popul[pop_size-1], D->nzones, D->nsfw);
        
        end = clock();
    }
    
    for (int i = 0; i < pop_size; i++)
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
