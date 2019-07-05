//
//  main.m
//  primesObjC
//
// 

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>



int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        int number;
        BOOL isPrime;
        int i, j, sq;
        
        NSMutableArray *result = [NSMutableArray array];
        [result addObject:@2];
        
        NSLog(@"Seek until what integer number ?");
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
            
            if (isPrime == true)
                [result addObject:[NSNumber numberWithInt:i]];
            
        } // outer for
        
        
        CFTimeInterval elapsedTime = CACurrentMediaTime() - startTime;
        
        NSUInteger count = [result count];
        NSLog(@"Found %lu primes.", (unsigned long)count);
        NSLog(@"Took %.3f s.", elapsedTime);
        //NSLog(@"%@", result);
    }
    return 0;
}
