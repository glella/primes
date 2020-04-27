//#include <stdio.h>
#include <mach/mach_time.h>

double timebase() {
    double  ratio;
    mach_timebase_info_data_t tb;

    mach_timebase_info(&tb);
    ratio = tb.numer / tb.denom;
    //printf("num: %u, den: %u\n", tb.numer, tb.denom);
    //printf("ratio from C: %.3f\n", ratio);

    return ratio;
}