// clang -O2 primes.c -o primes 

#include <stdio.h>
#import <time.h>
#include <math.h>

/***> Flush <***/
void Flush(void) { while (getchar() != '\n') ; } // end Flush


/***> GetCommand <***/
int GetCommand( void ) {
	char	command;

    Flush();
	do {
        scanf( "%c", &command );
    } while ( (command != 'y') && (command != 'Y')
              && (command != 'n') && (command != 'N'));

    if ((command == 'y') || (command == 'Y'))
        return( 1 );
    else
        return( 0 );
} // end GetCommand


/***> Main <***/
int main(int argc, char *argv[]) {
    #define kMaxNumber 50000000
    #define TRUE = 1
    #define FALSE = 0

    int         i,n, cant, num;
    //long int    num;
    double      r;
    clock_t     start, end;
    int         isPrime;
    int         numPrim[80000];
    float       sq;

    do {
        // main loop start and initialization
        numPrim[0]=2;
        cant=1;

        printf( "\n***-----***\n");
        printf("Seek primes until what number ? (Up to 5,000,000)");
        do {
            scanf("%i", &num);
        } while ( (num < 1) && (num > kMaxNumber));

        start = clock(); // start the clock

        for(i = 3; i <= num; i=i+2) {
            isPrime = 1;
            sq = sqrt(i);

            for(n = 3; (n <= (int)sq) && isPrime; n=n+2)
                if (i % n == 0)
                    isPrime = 0;

            if (isPrime) {
                numPrim[cant]=i;
                cant++;
            } // end if
        } // end for (main loop)

        end = clock(); // stop the clock
        r = ((double)(end-start)) / ((double)(CLOCKS_PER_SEC));

        // Print the primes
        printf("Found %i primes in %.3f Seconds.\n", cant, r);
        printf("Print them ? (y/n) ");
        if (GetCommand())
            for(i=0; i <= cant-1; i++)
                printf("%i,  ", numPrim[i]);

        // Again ?
        printf("\nAnother run ? (y/n) ");
    } while (GetCommand()); // end while

    return 0;
} // end Main
