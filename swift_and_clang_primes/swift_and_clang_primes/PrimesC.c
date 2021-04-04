//
//  PrimesC.c
//  primes
//
//  Created by Guillermo Lella on 1/30/21.
//

#include "PrimesC.h"

int c_1_Thread(int limit) {
    int     i, j, sq;
    int     isPrime, count;
    int     result[80000]; // 78498 primes in 1M
    
    result[0] = 2;
    count = 1;
    
    for (i = 3; i<= limit; i=i+2) {
        isPrime = 1;
        sq = (int)pow(i,0.5);
        
        for (j = 3; j <= sq; j=j+2) {
            if (i % j == 0) {
                isPrime = 0;
                break;
            } // if
        } // inner for
                
        if (isPrime == 1) {
            result[count] = i;
            count++;
        } // if
    } // outer for
    
    return count;
}
