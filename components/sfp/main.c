#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "config.h"
#include "genetic.h"
#include "structures.h"

int main(void)
{
    int a, b, c, d;
    int pop_size = POP_SIZE_DEFAULT;
    int mut_prom = MUT_PROM_DEFAULT;
    int time_limit = TIME_LIMIT_DEFAULT;
    struct data D;

    srand(time(NULL));

    scanf("%d%d%d%d", &a, &b, &c, &d);

    if (a != -1) pop_size   = a;
    if (b != -1) mut_prom   = b;
    if (c != -1) time_limit = c;
    if (d != -1) srand(d);

    init_data(&D);
    read_data(&D);
    int ret = check_data(&D);
    printf("check_data returned %d.\n", ret);
    if (ret != 0) return ret;

    struct creature* answer = genetic(&D, pop_size, mut_prom, time_limit);
    for (int i = 0; i < D.nzones; i++)
    {
        printf("Zone %d:\n", i+1);
        for (int j = 0; j < D.nsfw; j++)
        {
            printf("Object %d: %d %d\n", j+1, answer->P[i][j].x, answer->P[i][j].y);
        }
    }

    printf("Value: %d\n", evaluate(answer, &D, 1));
    print_mst(answer, &D);

    destroy_creature(answer, D.nzones);
    destroy_data(&D);

    free(answer);

    return 0;
}
