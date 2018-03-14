#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "genetic.hpp"

int main(void)
{
    // w jaki sposób korzystać z losowości?
    struct data D;

    read_data(&D);
    printf("check_data returned %d.\n", check_data(&D));
    //print_data(&D);

    /*for (int i = 0; i < D.zone[1].n; i++)
        for (int j = 0; j < D.zone[1].m; j++)
            if (check_placement(&D.zone[1], &D.objects[1][0], i, j) == 0)
            {
                printf("%d %d\n", i, j);
                place(&D.zone[1], &D.objects[1][0], i, j);
            }
    print_map(&D.zone[1]);*/

    /*int** res = (int**)malloc(sizeof(int*) * 20);
    for (int i = 0; i < 20; i++)
        res[i] = (int*)malloc(sizeof(int) * 20);

    bfs(&D.zone[1], res, D.pois[1][0].x, D.pois[1][0].y);*/

    /*struct creature p1, p2, ch;

    p1.P = (struct poi**)malloc(sizeof(struct poi*) * 2);
    p2.P = (struct poi**)malloc(sizeof(struct poi*) * 2);
    ch.P = (struct poi**)malloc(sizeof(struct poi*) * 2);
    for (int i = 0; i < 2; i++)
    {
        p1.P[i] = (struct poi*)malloc(sizeof(struct poi) * 3);
        p2.P[i] = (struct poi*)malloc(sizeof(struct poi) * 3);
        ch.P[i] = (struct poi*)malloc(sizeof(struct poi) * 3);
    }
    for (int i = 0; i < 2; i++)
        for (int j = 0; j < 3; j++)
        {
            p1.P[i][j].x = p1.P[i][j].y = 3*i + j;
            p2.P[i][j].x = p2.P[i][j].y = 3*i + j +100;
        }

    for (int k = 0; k < 3; k++)
    {
        crossover(&p1, &p2, &ch, 2, 3);

        for (int i = 0; i < 2; i++)
        {
            for (int j = 0; j < 3; j++)
                printf("%d %d\t", ch.P[i][j].x, ch.P[i][j].y);
            printf("\n");
        }
        printf("\n");
    }*/

    /*struct possible_positions P;

    create_possible_positions(&D, &P);

    for (int z = 0; z < D.nzones; z++)
    {
        for (int o = 0; o < D.nsfw; o++)
        {
            for (int k = 0; k < P.N[z][o]; k++)
                printf("%d %d\n", P.PP[z][o][k].x, P.PP[z][o][k].y);
            printf("\n");
        }
        printf("\n");
    }

    struct creature monster;
    monster.P = (struct poi**)malloc(sizeof(struct poi*) * D.nzones);
    for (int i = 0; i < D.nzones; i++)
        monster.P[i] = (struct poi*)malloc(sizeof(struct poi) * D.nsfw);

    crate_random_creature(&monster, &P, D.nzones, D.nsfw);

    for (int j = 0; j < 7; j++)
    {
        for (int i = 0; i < D.nzones; i++)
        {
            for (int j = 0; j < D.nsfw; j++)
                printf("%d %d\t", monster.P[i][j].x, monster.P[i][j].y);
            printf("\n");
        }
        printf("\n");

        mutation(&monster, &P, D.nzones, D.nsfw);
    }*/

    struct creature* answer = genetic(&D);
    for (int i = 0; i < D.nzones; i++)
    {
        printf("Zone %d:\n", i+1);
        for (int j = 0; j < D.nsfw; j++)
        {
            printf("Object %d: %d %d\n", j+1, answer->P[i][j].x, answer->P[i][j].y);
        }
    }
    printf("Value: %d\n", evaluate(answer, &D));

    return 0;
}
