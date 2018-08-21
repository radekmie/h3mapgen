#include "config.hpp"

struct map
{
    char** T;
    int n, m;
};

void read_map(struct map* M)
{
    scanf("%d%d", &M->n, &M->m);
    M->T = (char**)malloc(sizeof(char*) * M->n);
    for (int i = 0; i < M->n; i++)
    {
        M->T[i] = (char*)malloc(sizeof(char) * M->m + 1);
        scanf("%s", M->T[i]);
    }
}

void copy_map(struct map* src, struct map* dest)
{
    dest->n = src->n;
    dest->m = src->m;

    dest->T = (char**)malloc(sizeof(char*) * dest->n);
    for (int i = 0; i < dest->n; i++)
    {
        dest->T[i] = (char*)malloc(sizeof(char) * dest->m + 1);

        for (int j = 0; j < dest->m; j++)
            dest->T[i][j] = src->T[i][j];
    }
}

void destroy_map(struct map* M)
{
    for (int i = 0; i < M->n; i++)
        free(M->T[i]);
    free(M->T);
}

void map_print(struct map* M)
{
    for (int i = 0; i < M->n; i++)
        printf("%s\n", M->T[i]);
}

int check_map(struct map* M)
{
    for (int i = 0; i < M->n; i++)
        for (int j = 0; j < M->m; j++)
            if (M->T[i][j] != WALL && (M->T[i][j] != GROUND || i == 0 || j == 0 || i == M->n-1 || j == M->m-1))
                return MAP_UNEXPECTED_CHARACTER;
    return 0;
}

struct poi
{
    int x, y;
};

void read_poi(struct poi* P)
{
    scanf("%d%d", &P->x, &P->y);
}

void print_poi(struct poi* P)
{
    printf("%d %d\n", P->x, P->y);
}

struct pattern
{
    struct map M;
    struct poi P;
};

void read_pattern(struct pattern* T)
{
    read_map(&T->M);
    read_poi(&T->P);
}

void print_pattern(struct pattern* T)
{
    map_print(&T->M);
    print_poi(&T->P);
}

int check_pattern(struct pattern* T)
{
    for (int i = 0; i < T->M.n; i++)
        for (int j = 0; j < T->M.m; j++)
            if (T->M.T[i][j] != WALL && T->M.T[i][j] != GROUND && T->M.T[i][j] != BLANK)
                return PATTERN_UNEXPECTED_CHARACTER;
    if (T->P.x < 0 || T->P.x >= T->M.n || T->P.y < 0 || T->P.y >= T->M.m)
        return PATTERN_POI_OUT_OF_BOUND;
    return 0;
}

struct data
{
    int nzones;
    int npois1;
    int npois2;
    int nsfw;

    struct map*      zone;
    struct poi**     pois;
    struct pattern** objects;
};

void read_data(struct data* D)
{
    scanf("%d%d%d%d", &D->nzones, &D->npois1, &D->npois2, &D->nsfw);

    D->zone = (struct map*)malloc(sizeof(struct map) * D->nzones);
    D->pois = (struct poi**)malloc(sizeof(struct poi*) * D->nzones);
    D->objects = (struct pattern**)malloc(sizeof(struct pattern*) * D->nzones);

    for (int j = 0; j < D->nzones; j++)
    {
        read_map(&D->zone[j]);

        D->pois[j] = (struct poi*)malloc(sizeof(struct poi) * (D->npois1 + D->npois2));
        for (int i = 0; i < D->npois1 + D->npois2; i++)
            read_poi(&D->pois[j][i]);

        D->objects[j] = (struct pattern*)malloc(sizeof(struct pattern) * D->nsfw);
        for (int i = 0; i < D->nsfw; i++)
            read_pattern(&D->objects[j][i]);
    }
}

int is_on_list(struct poi* pois, int n, int x, int y)
{
    for (int i = 0; i < n; i++)
        if (pois[i].x == x && pois[i].y == y)
            return 1;
    return 0;
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
        if (r != 0) return r;
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
            if (r != 0) return r;
        }

    return 0;
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
