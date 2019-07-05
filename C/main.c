//
//  main.c
//  primesInC
//
//

#include <stdio.h>
#include <time.h>
#include <math.h>
#import <QuartzCore/QuartzCore.h>

int main(int argc, const char * argv[]) {
    
    int number;
    int isPrime;
    int i, j, sq;
    
    int cant = 1; // considering the number 2 case
    
    
    printf("Seek until what integer number ? ");
    scanf("%i", &number);
    
    CFTimeInterval startTime = CACurrentMediaTime();
    
    for (i = 3; i <= number; i=i+2)
    {
        isPrime = true;
        sq = (int)pow(i,0.5);
        
        for (j = 3; j <= sq; j=j+2) {
            if (i % j == 0) {
                isPrime = false;
                break;
            } // if
            
        } // inner for
        
        if (isPrime == true) {
            cant++;
            //printf("%i ", i);
        } // if
        
    } // outer for
    
    
    CFTimeInterval elapsedTime = CACurrentMediaTime() - startTime;
    
    printf("elapsed time: %5.3f s.\n", elapsedTime);
    printf("Found %i primess.\n", cant);
    
    
    return 0;
}
