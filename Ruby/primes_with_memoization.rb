#! /usr/bin/env ruby
# ruby primes_with_memoization.rb
# works but it is very slow - improvements from caching offset
# by creating arrays + copying the data, etc. 

def prompt(*args)
    print(*args)
    gets
end

def is_prime(i)
	#return $result.inlude?(i) if i <= $result[-1]
	#return false if $result.any? { |d| i % d == 0 }
	limit = Math.sqrt(i)	
	divisors = $result + ($result[-1]+2..limit).step(2).to_a				# divide by cached primes until sqrt limit
	$result << i if divisors.none? { |d| i % d == 0 }
end

# def getPrimeList(n)
# 	return [] if n < 2
# 	result = [2]
# 	# do only odd numbers starting at 3
# 	odd = (3...n).step(2).to_a

# 	odd.each do |i|	
# 		divisors = (3..Math.sqrt(i)).step(2)
# 		result << i if divisors.none? { |d| i % d == 0 }
# 	end

# 	return result
# end


puts "Returns a list of prime numbers from 1 to < n using trial division algorithm."
n = (prompt "Input limit: ").to_i

start_time = Time.now
#list = getPrimeList(n)
$result = [2]
odd = (3...n).step(2).to_a
odd.map{ |x| is_prime(x) }
end_time = Time.now

elapsed_time = end_time - start_time
puts "found #{$result.length} primes"
printf("elapsed time: %5.3f s.\n", elapsed_time)

answer = prompt "Print them ? (y/n) "
puts $result.inspect if answer.strip == 'y'

