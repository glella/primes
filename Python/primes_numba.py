#!/usr/bin/env python
# python primes_numba.py

import time
from numba import jit

@jit(nopython=True) # Set "nopython" mode for best performance, equivalent to @njit
def getPrimeList(n):
    """ Returns a list of prime numbers from 1 to < n using trial division algorithm"""
    resList = [2]
    #if n <= 1: return []
    if n == 2: return resList

    # do only odd numbers starting at 3
    for i in range(3, n, 2):
        primo = True
        sq = i ** 0.5

        for j in range(3, int(sq+1), 2):
            if (i % j) == 0:
                primo = False
                break
        if primo:
            resList.append(i)

    return resList



if __name__ == "__main__":
    print("\nLooks for prime numbers from 1 to your input")
    cont = True

    while cont:
        n = int(input('Seek until what integer number ? '))

        t1 = time.time()
        primeList = getPrimeList(n)
        t2 = time.time()

        print('Found %i prime numbers. Took %0.3fsec.' % (len(primeList),t2-t1))

        if ((input('Print prime numbers ? (y/n) ')) == ('y' or 'Y')):
            print(primeList)


        if ((input('Another run ? (y/n) ')) != ('y' or 'Y')):
            cont = False


        print



