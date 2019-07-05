! primes in basic

cls 

print "Returns a list of prime numbers from 1 to < n using trial division algorithm."
input "Seek until what number", num

list.create n, result
list.add result, 2

start = clock()

for i = 3 to num step 2

	isPrime = 1
	sq = INT(POW(i,0.5))
	
	for n = 3 to sq step 2
		if MOD(i,n) = 0 
			isPrime = 0
			F_N.break
		endif
	next n

	if isPrime = 1 
		list.add result, i
  !print I;" ";
	endif
	
next i

elapsed = clock() - start

print
list.size result, size
print "Found "; size; " primes."
print "Took "; elapsed / 1000; " seconds."
print
for x = 1 to size
    list.get result, x, temp               
    print str$(temp); ", ";     
next x

