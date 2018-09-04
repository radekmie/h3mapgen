#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include "config.h"
#include "genetic.h"
#include "structures.h"

#define dn 8
int dx[dn] = {-1,  1,  0,  0, -1,  1, -1,  1};
int dy[dn] = { 0,  0,  1, -1, -1, -1,  1,  1};

void crate_random_creature(struct creature* monster, struct possible_positions* P, int nzones, int nsfw)
{
    for (int i = 0; i < nzones; i++)
        for (int j = 0; j < nsfw; j++)
            monster->P[i][j] = P->PP[i][j][ rand() % P->N[i][j] ];
}

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

void mutation(struct creature* monster, struct possible_positions* P, int nzones, int nsfw, int mut)
{
    for (int i = 0; i < nzones; i++)
        for (int j = 0; j < nsfw; j++)
            if (rand()%1000 < mut)
                monster->P[i][j] = P->PP[i][j][ rand() % P->N[i][j] ];
}

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

void addpath(int** bfs_results, struct map* printmap, int sx, int sy)
{
    int cx = sx;
    int cy = sy;

    while (bfs_results[cx][cy] != 0)
    {
        //if (printmap.T[cx][cy] == GROUND)
        printmap->T[cx][cy] = TRACK;

        int l = 0;
        while (l < dn && ((printmap->T[cx+dx[l]][cy+dy[l]] != GROUND && printmap->T[cx+dx[l]][cy+dy[l]] != TRACK) || bfs_results[cx+dx[l]][cy+dy[l]] >= bfs_results[cx][cy]))
            l++;
        if (l == dn) break;
        cx += dx[l];
        cy += dy[l];
    }

    printmap->T[cx][cy] = TRACK;
}

void path_repair(struct map* M)
{
    for (int i = 0; i < M->n - 1; i++)
        for (int j = 0; j < M->m - 1; j++)
        {
            if (M->T[i][j] == TRACK && M->T[i+1][j+1] == TRACK && M->T[i][j+1] != TRACK && M->T[i+1][j] != TRACK)
            {
                if      (M->T[i][j+1] == GROUND) M->T[i][j+1] = TRACK;
                else if (M->T[i+1][j] == GROUND) M->T[i+1][j] = TRACK;
            }
            else if (M->T[i][j] != TRACK && M->T[i+1][j+1] != TRACK && M->T[i][j+1] == TRACK && M->T[i+1][j] == TRACK)
            {
                if      (M->T[i][j] == GROUND)     M->T[i][j]     = TRACK;
                else if (M->T[i+1][j+1] == GROUND) M->T[i+1][j+1] = TRACK;
            }
        }
}

int evaluate(struct creature* monster, struct data* D, int print)
{
    int obj2poi[D->nzones][D->nsfw][D->npois1 + D->npois2];
    int obj2obj[D->nzones][D->nsfw][D->nsfw];

    int result = 0;

    for (int i = 0; i < D->nzones; i++)
    {
        int **bfs_results;
        struct map temp_map;
        //struct map printmap;

        // Tworzenie struktur //
        init_map(&temp_map);
        //init_map(&printmap);

        //if (print == 1) copy_map(&temp_map, &printmap);

        bfs_results = (int**)malloc(sizeof(int*) * D->zone[i].n);
        for (int j = 0; j < D->zone[i].n; j++)
            bfs_results[j] = (int*)malloc(sizeof(int) * D->zone[i].m);

        // Umieszamy w temp_map wszystkie obiekty //
        copy_map(&D->zone[i], &temp_map);
        for (int j = 0; j < D->nsfw; j++)
        {
            if (check_placement(&temp_map, &D->objects[i][j], monster->P[i][j].x, monster->P[i][j].y) != 0)
                result = oo;
            place(&temp_map, &D->objects[i][j], monster->P[i][j].x, monster->P[i][j].y);
        }

        // obliamy wartosci tablic obj2poi oraz obj2obj //
        for (int j = 0; j < D->nsfw; j++)
        {
            bfs(&temp_map, bfs_results, monster->P[i][j].x, monster->P[i][j].y);

            for (int k = 0; k < D->npois1 + D->npois2; k++)
            {
                obj2poi[i][j][k] = bfs_results[ D->pois[i][k].x ][ D->pois[i][k].y ];
                if (obj2poi[i][j][k] == oo) result = oo;

                //if (print == 1) addpath(bfs_results, &printmap, D->pois[i][k].x, D->pois[i][k].y);
            }

            for (int k = 0; k < D->nsfw; k++)
            {
                obj2obj[i][j][k] = bfs_results[ monster->P[i][k].x ][ monster->P[i][k].y ];
                if (obj2obj[i][j][k] == oo) result = oo;

                //if (print == 1) addpath(bfs_results, &printmap, monster->P[i][k].x, monster->P[i][k].y);
            }
        }

        // wypisujemy mapy z zaznaonymi sciezkami all - all //
        /*if (print == 1)
        {
            print_map(&printmap);
            printf("\n");
        }*/

        // Destruktory //
        destroy_map(&temp_map);
        //if (print == 1) destroy_map(&printmap);

        for (int j = 0; j < D->zone[i].n; j++)
            free(bfs_results[j]);
        free(bfs_results);

        if (result == oo)
            return oo;
    }

    // Wypisujemy tablice obj2poi oraz obj2obj //
    if (print == 1)
    {
        fprintf(stderr, "obj2poi tables:\n");
        for (int i = 0; i < D->nzones; i++)
        {
            fprintf(stderr, "Zone: %d\n", i+1);
            for (int j = 0; j < D->nsfw; j++)
            {
                for (int k = 0; k < D->npois1 + D->npois2; k++)
                    fprintf(stderr, "%d ", obj2poi[i][j][k]);
                fprintf(stderr, "\n");
            }
            fprintf(stderr, "\n");
        }

        fprintf(stderr, "obj2obj tables:\n");
        for (int i = 0; i < D->nzones; i++)
        {
            fprintf(stderr, "Zone: %d\n", i+1);
            for (int j = 0; j < D->nsfw; j++)
            {
                for (int k = 0; k < D->nsfw; k++)
                    fprintf(stderr, "%d ", obj2obj[i][j][k]);
                fprintf(stderr, "\n");
            }
            fprintf(stderr, "\n");
        }
    }

    // Liczymy wartosc ewaluacji na podstawie tablic obj2obj oraz obj2poi

    for (int i = 0; i < D->nzones; i++)
        for (int j = i+1; j < D->nzones; j++)
            for (int k = 0; k < D->nsfw; k++)
            {
                for (int l = 0; l < D->npois1 + D->npois2; l++)
                    result += (obj2poi[i][k][l] - obj2poi[j][k][l]) * (obj2poi[i][k][l] - obj2poi[j][k][l]);
                for (int l = 0; l < D->nsfw; l++)
                    result += (obj2obj[i][k][l] - obj2obj[j][k][l]) * (obj2obj[i][k][l] - obj2obj[j][k][l]);
            }

    // Sortowanie //
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

void print_mst(struct creature* monster, struct data* D)
{
    // Czesc I: liczymy drzewo //
    int N = D->nsfw + D->npois1 + D->npois2;
    int G[N][N];
    int **bfs_results;
    struct ijval { int i, j, value; } T[N*N];
    struct map temp_map;

    // Konstruktory //
    init_map(&temp_map);

    bfs_results = (int**)malloc(sizeof(int*) * D->zone[0].n);
    for (int j = 0; j < D->zone[0].n; j++)
        bfs_results[j] = (int*)malloc(sizeof(int) * D->zone[0].m);

    // Umieszczamy obiekty na mapie //
    copy_map(&D->zone[0], &temp_map);
    for (int j = 0; j < D->nsfw; j++)
    {
        if (check_placement(&temp_map, &D->objects[0][j], monster->P[0][j].x, monster->P[0][j].y) != 0)
            return;
        place(&temp_map, &D->objects[0][j], monster->P[0][j].x, monster->P[0][j].y);
    }

    // Liczymy odleglosci miedzy obiektami //
    for (int i = 0; i < N; i++)
        for (int j = 0; j < N; j++)
            G[i][j] = oo;

    for (int j = 0; j < D->nsfw; j++)
    {
        bfs(&temp_map, bfs_results, monster->P[0][j].x, monster->P[0][j].y);

        for (int k = 0; k < D->npois1 + D->npois2; k++)
            G[D->nsfw + k][j] = G[j][D->nsfw + k] = bfs_results[ D->pois[0][k].x ][ D->pois[0][k].y ];

        for (int k = 0; k < D->nsfw; k++)
            G[k][j] = G[j][k] = bfs_results[ monster->P[0][k].x ][ monster->P[0][k].y ];
    }

    // Destruktory //
    destroy_map(&temp_map);

    for (int j = 0; j < D->zone[0].n; j++)
        free(bfs_results[j]);
    free(bfs_results);

    // Czesc II: Tworzymy drzewo //

    // Umieszczamy elementy w tablicy //
    int T_size = 0;
    for (int i = 0; i < N; i++)
        for (int j = i+1; j < N; j++)
        {
            T[T_size].i = i;
            T[T_size].j = j;
            T[T_size].value = G[i][j];
            T_size++;
        }

    // Sortujemy elementy w tablicy T //
    for (int i = 0; i < T_size-1; i++)
        for (int j = 0; j < T_size-1; j++)
            if (T[j].value > T[j+1].value)
            {
                struct ijval tmp = T[j];
                T[j] = T[j+1];
                T[j+1] = tmp;
            }

    // Konstruujemy drzewo algorytmem Kruskala //
    int tree_size = 0;
    int findunion[N];
    struct poi Tree[N];

    init_findunion(findunion, N);
    for (int i = 0; i < T_size; i++)
        if (union_findunion(findunion, T[i].i, T[i].j) == 0)
        {
            Tree[tree_size].x = T[i].i;
            Tree[tree_size].y = T[i].j;
            tree_size++;
        }

    // Czesc III: Wypisujemy mapy //
    for (int i = 0; i < D->nzones; i++)
    {
        // Konstruktor //
        bfs_results = (int**)malloc(sizeof(int*) * D->zone[i].n);
        for (int j = 0; j < D->zone[i].n; j++)
            bfs_results[j] = (int*)malloc(sizeof(int) * D->zone[i].m);

        // Kopiujemy mape i umieszczamy na niej wszystkie obiekty //
        copy_map(&D->zone[i], &temp_map);
        for (int j = 0; j < D->nsfw; j++)
        {
            if (check_placement(&temp_map, &D->objects[i][j], monster->P[i][j].x, monster->P[i][j].y) != 0)
                return;
            place(&temp_map, &D->objects[i][j], monster->P[i][j].x, monster->P[i][j].y);
        }

        // Umieszczamy sciezke na mapie //
        for (int j = 0; j < tree_size; j++)
        {
            struct poi pfrom;
            struct poi pto;

            if (Tree[j].x < D->nsfw)
                pfrom = monster->P[i][ Tree[j].x ];
            else
                pfrom = D->pois[i][ Tree[j].x - D->nsfw ];

            if (Tree[j].y < D->nsfw)
                pto = monster->P[i][ Tree[j].y ];
            else
                pto = D->pois[i][ Tree[j].y - D->nsfw ];

            bfs(&temp_map, bfs_results, pfrom.x, pfrom.y);

            addpath(bfs_results, &temp_map, pto.x, pto.y);
        }

        // Wypisujemy mape //
        path_repair(&temp_map);
        print_map(&temp_map);
        printf("\n");

        // Destruktor //
        for (int j = 0; j < D->zone[i].n; j++)
            free(bfs_results[j]);
        free(bfs_results);

        destroy_map(&temp_map);
    }
}

struct creature* genetic(struct data* D, int pop_size, int mut_prom, int time_limit)
{
    int no_impr = 0;
    struct creature bst[pop_size];
    struct creature popul[pop_size];
    int values[pop_size];
    struct possible_positions possible;
    struct creature* best_creature;
    int best_value = oo;
    clock_t start = clock(), end;

    // Konstruktory //
    create_possible_positions(D, &possible);

    best_creature = (struct creature*)malloc(sizeof(struct creature));
    init_creature(best_creature);
    alloc_creature(best_creature, D->nzones, D->nsfw);

    for (int i = 0; i < pop_size; i++)
    {
        init_creature(&bst[i]);
        alloc_creature(&bst[i], D->nzones, D->nsfw);

        init_creature(&popul[i]);
        alloc_creature(&popul[i], D->nzones, D->nsfw);
    }

    // Tworzymy pierwsza populacje w sposob losowy
    for (int i = 0; i < pop_size; i++)
        crate_random_creature(&popul[i], &possible, D->nzones, D->nsfw);

    end = clock();

    int iteration_number = 1;

    while (((double) (end - start)) * 1000 / CLOCKS_PER_SEC < time_limit)
    {
        // oceniamy kazdego z osobnikow
        for (int i = 0; i < pop_size; i++)
            values[i] = evaluate(&popul[i], D, 0);

        // Sortujemy wartosci
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

        // Sprawdzamy czy znalezlismy nowego lepszego osobnika
        if (values[0] < best_value)
        {
            no_impr = 0;
            best_value = values[0];
            copy_creature(&popul[0], best_creature, D->nzones, D->nsfw);
        }
        else if (++no_impr >= 5) break; // Jesli przez piec kolejnych tur nie znalezlismy lepszego osobnika - konczymy

        fprintf(stderr, "Iteration: %d best value: %d\n", iteration_number++, best_value);

        // Tworzymy nowa populacje

        // Tworzymy tablice pomocnicza bst do ktorej umieszczamy osobnikow z poprzedniej iteracji
        // _starajac sie_ przy okazji usunac duplikaty
        int bst_n = 1;
        int pop_n = 0;
        copy_creature(&popul[0], &bst[0], D->nzones, D->nsfw);

        for (int i = 1; i < pop_size; i++)
        {
            int is_in = 0;
            for (int j = 0; j < bst_n; j++)
                if (compare_creature(&popul[i], &bst[j], D->nzones, D->nsfw) == 1)
                    is_in = 1;
            if (is_in == 0)
                copy_creature(&popul[i], &bst[bst_n++], D->nzones, D->nsfw);
        }

        // Ten if trigeruje sie gdy poprzednia iteracja skladala sie z jednego i tego samego osobnika
        if (bst_n == 1) break;

        // Krzyzujemy osobnikow metoda kazdy z kazdym zaczynajac od tych z najlepszym przystosowaniem
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
                // Jesli w populacji bylo malo osobnikow to zwiekszamy prawdopodobienstwo mutacji
                mut *= 5;
                it2 = 1;
            }
        }
        // Kopiujemy najlepszego osobnika z powrotem do populacji
        copy_creature(best_creature, &popul[pop_size-1], D->nzones, D->nsfw);

        end = clock();
    }

    // Destruktory //
    for (int i = 0; i < pop_size; i++)
    {
        destroy_creature(&bst[i], D->nzones);
        destroy_creature(&popul[i], D->nzones);
    }

    destroy_possible_positions(D, &possible);

    // Zwracamy wynik //
    return best_creature;
}

