//
//  PrimesObjC.m
//  primes
//
//  Created by Guillermo Lella on 1/30/21.
//

#import <Foundation/Foundation.h>

int objC_1_Thread(int limit) {
    @autoreleasepool {
        BOOL isPrime;
        int i, j, sq;
        
        NSMutableArray *result = [NSMutableArray array];
        [result addObject:@2];
            
        for (i = 3; i <= limit; i=i+2) {
            isPrime = true;
            sq = (int)pow(i,0.5);
                
            for (j = 3; j <= sq; j=j+2) {
                if (i % j == 0) {
                    isPrime = false;
                    break;
                } // if
            } // inner for
            if (isPrime == true)
                [result addObject:[NSNumber numberWithInt:i]];
        } // outer for
        
        return (int)[result count];
    }
}
