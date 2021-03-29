# ruby primes_erastosthenes.rb
#! /usr/bin/env ruby

def prompt(*args)
    print(*args)
    gets
end

def getPrimeList(n)
	return [] if n < 2
	result = [2]

	# do only odd numbers starting at 3
	odd = (3...n).step(2).to_a

	odd.each do |i|
		divisors = (3..Math.sqrt(i)).step(2)
		result << i if divisors.none? { |d| i % d == 0 }
	end

	return result
end

def eratosthenes(n)
	nums = [nil, nil, *2..n]

	(2..Math.sqrt(n)).each do |i|
		(i**2..n).step(i) {|m| nums[m] = nil}  #if nums[i]
  	end
  	nums.compact
end

puts "Returns a list of prime numbers from 1 to < n using trial division algorithm."
n = (prompt "Input limit: ").to_i

start_time = Time.now
#list = getPrimeList(n)
list = eratosthenes(n)
end_time = Time.now

elapsed_time = end_time - start_time
puts "found #{list.length} primes"
printf("elapsed time: %5.3f s.\n", elapsed_time)

answer = prompt "Print them ? (y/n) "
puts list.inspect if answer.strip == 'y'

