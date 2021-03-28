#!/usr/bin/env python
# python primes_rust_module.py

import time
import primesrs


if __name__ == "__main__":
    print("\nLooks for prime numbers from 1 to your input in prallel through rust & rayon")
    cont = True

    while cont:
        n = int(input('Seek until what integer number ? '))

        t1 = time.time()
        primeList = primesrs.getlist(n)
        t2 = time.time()

        print('Found %i prime numbers. Took %0.3fsec.' % (len(primeList),t2-t1))
        if ((input('Print prime numbers ? (y/n) ')) == ('y' or 'Y')):
            print(primeList)


        if ((input('Another run ? (y/n) ')) != ('y' or 'Y')):
            cont = False
        print



