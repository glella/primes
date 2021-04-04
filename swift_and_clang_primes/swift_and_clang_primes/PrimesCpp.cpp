//
//  PrimesCpp.cpp
//  primes
//
//  Created by Guillermo Lella on 1/30/21.
//

#include "PrimesCpp.hpp"

extern "C" int cpp_1_Thread(int limit) {
    int     i, j, sq, count;
    bool    isPrime;
    int     result[80000]; // 78498 primes in 1M
    
    result[0] = 2;
    count = 1;
    
    for (i = 3; i<= limit; i=i+2) {
        isPrime = true;
        sq = (int)pow(i,0.5);
        
        for (j = 3; j <= sq; j=j+2) {
            if (i % j == 0) {
                isPrime = false;
                break;
            } // if
        } // inner for
                
        if (isPrime == true) {
            result[count] = i;
            count++;
        } // if
    } // outer for
    
    return count;
}
