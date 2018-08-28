#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "config.h"
#include "structures.h"

void init_map(struct map* M)
{
    M->T = NULL;
    M->n = M->m = 0;
}

void alloc_map(struct map* M, int n, int m)
{
    if (M->T == NULL || M->n != n || M->m != m)
    {
        destroy_map(M);

        M->n = n;
        M->m = m;

        M->T = (char**)malloc(sizeof(char*) * n);
        for (int i = 0; i < M->n; i++)
            M->T[i] = (char*)malloc(sizeof(char) * (m + 1));
    }
}

void destroy_map(struct map* M)
{
    if (M->T != NULL)
    {
        for (int i = 0; i < M->n; i++)
            free(M->T[i]);
        free(M->T);
        M->T = NULL;
        M->n = M->m = 0;
    }
}

void read_map(struct map* M)
{
    int n, m;

    scanf("%d%d", &n, &m);

    alloc_map(M, n, m);

    for (int i = 0; i < n; i++)
        scanf("%s", M->T[i]);
}

void print_map(struct map* M)
{
    for (int i = 0; i < M->n; i++)
        printf("%s\n", M->T[i]);
}

void copy_map(struct map* src, struct map* dest)
{
    alloc_map(dest, src->n, src->m);

    for (int i = 0; i < dest->n; i++)
        memcpy(dest->T[i], src->T[i], sizeof(char) * (dest->m + 1));
}

int check_map(struct map* M)
{
    for (int i = 0; i < M->n; i++)
    {
        for (int j = 0; j < M->m; j++)
            if (M->T[i][j] != WALL && (M->T[i][j] != GROUND || i == 0 || j == 0 || i == M->n-1 || j == M->m-1))
                return MAP_UNEXPECTED_CHARACTER;
        if (M->T[i][M->m] != '\0')
            return MAP_UNEXPECTED_CHARACTER;
    }
    return NO_ERROR;
}

void init_poi(struct poi* P)
{
    P->x = P->y = -1;
}

void read_poi(struct poi* P)
{
    scanf("%d%d", &P->x, &P->y);
}

void print_poi(struct poi* P)
{
    printf("%d %d\n", P->x, P->y);
}

int is_on_list(struct poi* pois, int n, int x, int y)
{
    for (int i = 0; i < n; i++)
        if (pois[i].x == x && pois[i].y == y)
            return 1;
    return 0;
}

void init_pattern(struct pattern* P)
{
    init_map(&(P->M));
    init_poi(&(P->P));
}

void destroy_pattern(struct pattern* P)
{
    destroy_map(&(P->M));
}

void read_pattern(struct pattern* T)
{
    read_map(&T->M);
    read_poi(&T->P);
}

void print_pattern(struct pattern* T)
{
    print_map(&T->M);
    print_poi(&T->P);
}

int check_pattern(struct pattern* T)
{
    for (int i = 0; i < T->M.n; i++)
    {
        for (int j = 0; j < T->M.m; j++)
            if (T->M.T[i][j] != WALL && T->M.T[i][j] != GROUND && T->M.T[i][j] != BLANK)
                return PATTERN_UNEXPECTED_CHARACTER;
        if (T->M.T[i][T->M.m] != '\0')
            return PATTERN_UNEXPECTED_CHARACTER;
    }

    if (T->P.x < 0 || T->P.x >= T->M.n || T->P.y < 0 || T->P.y >= T->M.m)
        return PATTERN_POI_OUT_OF_BOUND;

    return NO_ERROR;
}

int check_placement(struct map* M, struct pattern* P, int x, int y)
{
    int ux = x - P->P.x;
    int dx = ux + P->M.n;
    int ly = y - P->P.y;
    int ry = ly + P->M.m;

    if (ux < 0 || dx >= M->n || ly < 0 || ry >= M->m)
        return 1;

    for (int i = ux; i < dx; i++)
        for (int j = ly; j < ry; j++)
            if (P->M.T[i-ux][j-ly] != BLANK && M->T[i][j] == WALL)
                return 1;

    return 0;
}

void place(struct map* M, struct pattern* P, int x, int y)
{
    int ux = x - P->P.x;
    int dx = ux + P->M.n;
    int ly = y - P->P.y;
    int ry = ly + P->M.m;

    for (int i = ux; i < dx; i++)
        for (int j = ly; j < ry; j++)
            if (P->M.T[i-ux][j-ly] != BLANK)
                M->T[i][j] = P->M.T[i-ux][j-ly];
}

void init_data(struct data* D)
{
    D->nzones = D->npois1 = D->npois2 = D->nsfw = 0;
    D->zone = NULL;
    D->pois = NULL;
    D->objects = NULL;
}

void alloc_data(struct data* D, int nzones, int npois1, int npois2, int nsfw)
{
    destroy_data(D);

    D->nzones = nzones;
    D->npois1 = npois1;
    D->npois2 = npois2;
    D->nsfw   = nsfw;

    D->zone = (struct map*)malloc(sizeof(struct map) * D->nzones);
    D->pois = (struct poi**)malloc(sizeof(struct poi*) * D->nzones);
    D->objects = (struct pattern**)malloc(sizeof(struct pattern*) * D->nzones);

    for (int j = 0; j < D->nzones; j++)
    {
        init_map(&(D->zone[j]));

        D->pois[j] = (struct poi*)malloc(sizeof(struct poi) * (D->npois1 + D->npois2));
        for (int i = 0; i < D->npois1 + D->npois2; i++)
            init_poi(&D->pois[j][i]);

        D->objects[j] = (struct pattern*)malloc(sizeof(struct pattern) * D->nsfw);
        for (int i = 0; i < D->nsfw; i++)
            init_pattern(&D->objects[j][i]);
    }
}

void destroy_data(struct data* D)
{
    if (D->zone != NULL) {
        for (int j = 0; j < D->nzones; j++)
            destroy_map(&D->zone[j]);
        free(D->zone);
    }

    if (D->pois != NULL)
    {
        for (int j = 0; j < D->nzones; j++)
            free(D->pois[j]);
        free(D->pois);
    }

    if (D->objects != NULL)
    {
        for (int j = 0; j < D->nzones; j++) {
            for (int i = 0; i < D->nsfw; i++)
                destroy_pattern(&D->objects[j][i]);
            free(D->objects[j]);
        }
        free(D->objects);
    }

    D->nzones = D->npois1 = D->npois2 = D->nsfw = 0;
    D->zone = NULL;
    D->pois = NULL;
    D->objects = NULL;
}

void read_data(struct data* D)
{
    int nzones, npois1, npois2, nsfw;

    scanf("%d%d%d%d", &nzones, &npois1, &npois2, &nsfw);
    alloc_data(D, nzones, npois1, npois2, nsfw);

    for (int j = 0; j < nzones; j++)
    {
        read_map(&D->zone[j]);

        for (int i = 0; i < npois1 + npois2; i++)
            read_poi(&D->pois[j][i]);

        for (int i = 0; i < nsfw; i++)
            read_pattern(&D->objects[j][i]);
    }
}

void print_data(struct data* D)
{
    for (int k = 0; k < D->nzones; k++)
    {
        printf("Zone %d:\n", k);

        for (int i = 0; i < D->zone[k].n; i++)
        {
            for (int j = 0; j < D->zone[k].m; j++)
                if (is_on_list(D->pois[k], D->npois1 + D->npois2, i, j))
                    printf("!");
                else
                    printf("%c", D->zone[k].T[i][j]);
            printf("\n");
        }

        printf("Templates:\n");

        for (int l = 0; l < D->nsfw; l++)
        {
            for (int i = 0; i < D->objects[k][l].M.n; i++)
            {
                for (int j = 0; j < D->objects[k][l].M.m; j++)
                    if (i == D->objects[k][l].P.x && j == D->objects[k][l].P.y)
                        printf("!");
                    else
                        printf("%c", D->objects[k][l].M.T[i][j]);
                printf("\n");
            }

            printf("\n");
        }
    }
}

int check_data(struct data* D)
{
    for (int k = 0; k < D->nzones; k++)
    {
        int r = check_map(&D->zone[k]);
        if (r != NO_ERROR) return r;
    }

    for (int k = 0; k < D->nzones; k++)
    {
        for (int l = 0; l < D->npois1 + D->npois2; l++)
            if (D->pois[k][l].x <= 0 || D->pois[k][l].x >= D->zone[k].n-1 || D->pois[k][l].y <= 0 || D->pois[k][l].y >= D->zone[k].m-1)
                return MAP_POI_OUT_OF_BOUND;
    }

    for (int k = 0; k < D->nzones; k++)
        for (int l = 0; l < D->nsfw; l++)
        {
            int r = check_pattern(&D->objects[k][l]);
            if (r != NO_ERROR) return r;
        }

    return NO_ERROR;
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
                fprintf(stderr, "Fatal Error: Cannot place objects\n");
                exit(CANNOT_PLACE_OBJECT);
            }
        }
    }
}

void destroy_possible_positions(struct data* D, struct possible_positions* P)
{
    for (int z = 0; z < D->nzones; z++)
    {
        for (int o = 0; o < D->nsfw; o++)
            free(P->PP[z][o]);
        free(P->PP[z]);
        free(P->N[z]);
    }

    free(P->PP);
    free(P->N);
}

void init_findunion(int* fu, int size)
{
    for (int i = 0; i < size; i++)
        fu[i] = i;
}

int find_findunion(int* fu, int i)
{
    if (fu[i] != i)
        fu[i] = find_findunion(fu, fu[i]);
    return fu[i];
}

int union_findunion(int* fu, int i, int j)
{
    i = find_findunion(fu, i);
    j = find_findunion(fu, j);

    if (i == j) return 1;

    fu[i] = j;
    return 0;
}

void init_creature(struct creature* C)
{
    C->P = NULL;
}

void alloc_creature(struct creature* C, int nzones, int nsfw)
{
    C->P = (struct poi**)malloc(sizeof(struct poi*) * nzones);
    for (int j = 0; j < nzones; j++)
        C->P[j] = (struct poi*)malloc(sizeof(struct poi) * nsfw);
}

void destroy_creature(struct creature* C, int nzones)
{
    if (C->P != NULL)
    {
        for (int j = 0; j < nzones; j++)
            free(C->P[j]);
        free(C->P);

        C->P = NULL;
    }
}

void copy_creature(struct creature* src, struct creature* dest, int nzones, int nsfw)
{
    for (int i = 0; i < nzones; i++)
        memcpy(dest->P[i], src->P[i], sizeof(struct poi) * nsfw);
}

int compare_creature(struct creature* one, struct creature* two, int nzones, int nsfw)
{
    for (int i = 0; i < nzones; i++)
        for (int j = 0; j < nsfw; j++)
            if (one->P[i][j].x != two->P[i][j].x || one->P[i][j].y != two->P[i][j].y)
                return 0;
    return 1;
}
