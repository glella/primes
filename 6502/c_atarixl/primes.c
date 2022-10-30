// primes.c
// cl65 -O -t atarixl -o primes.xex -l primes.list primes.c sqrt.s

#include <stdio.h>
#include <time.h>
#include <stdlib.h>

#define kMaxNumber 50000L

/* Workaround missing clock stuff */
#ifdef __APPLE2__
#define clock() 0
#define CLOCKS_PER_SEC 1
#endif

// variables need to be global
unsigned int i, n, cant, num;
int isPrime;
int numPrim[5200];
int sq;
/* Clock variables */
clock_t Ticks;
unsigned Sec;
unsigned Milli;

// "fastcall" assembly call - param LSB in A and MSB in X - return uses same registers
extern unsigned int __fastcall__ sqrt(unsigned int a);

/***> Flush <***/
void Flush(void)
{
    while (getchar() != '\n')
        ;
} // end Flush

/***> GetCommand <***/
int GetCommand(void)
{
    char command;

    Flush();
    do
    {
        scanf("%c", &command);
    } while ((command != 'y') && (command != 'Y') && (command != 'n') && (command != 'N'));

    if ((command == 'y') || (command == 'Y'))
        return (1);
    else
        return (0);
} // end GetCommand

/***> Main <***/
// int main(int argc, char *argv[])
int main()
{
    do
    {
        // main loop start and initialization
        numPrim[0] = 2;
        cant = 1;

        printf("\n***-----***\n");
        printf("Seek primes until what number ? (Up to 50,000)");
        do
        {
            scanf("%i", &num);
        } while ((num < 1) && (num > kMaxNumber));

        Ticks = clock(); // start the clock

        for (i = 3; i <= num; i = i + 2)
        {
            isPrime = 1;
            sq = sqrt(i);
            // printf("sqrt of %i is %i\n", i, sq);

            for (n = 3; (n <= sq) && isPrime; n = n + 2)
            // for (n = 3; (n < i) && isPrime; n = n + 2) // does not use sqrt limit
            {
                if (i % n == 0)
                    isPrime = 0;
            }

            if (isPrime)
            {
                numPrim[cant] = i;
                cant++;
            } // end if
        }     // end for (main loop)

        Ticks = clock() - Ticks; // calculate elapsed time
        Sec = (unsigned)(Ticks / CLOCKS_PER_SEC);
        Milli = ((Ticks % CLOCKS_PER_SEC) * 1000) / CLOCKS_PER_SEC;

        // Print the primes
        printf("Found %i primes in %u.%03u seconds\n", cant, Sec, Milli);
        printf("Print them ? (y/n) ");
        if (GetCommand())
            for (i = 0; i <= cant - 1; i++)
                printf("%i,  ", numPrim[i]);

        // Again ?
        printf("\nAnother run ? (y/n) ");

    } while (GetCommand()); // end while

    return 0;

} // end Main
