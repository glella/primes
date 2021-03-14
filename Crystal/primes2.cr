#! /usr/bin/env ruby

def prompt(*args)
    print(*args)
    gets
end

def getPrimeList(n)
	return Array(Int32).new if n < 2
	result = [2]

	# do only odd numbers starting at 3
	odd = (3...n).step(2).to_a

	odd.each do |i|
		result << i if inner_loop(i)
	end

	return result
end


def inner_loop(e)
	is_prime = true

	num = (e ** 0.5).round
	range = (3..num).step(2).to_a
	
	#(2..e).each do |i|
	range.each do |i|
		next if i == e
		if e % i == 0
			is_prime = false
			break
		end
	end
	return is_prime
end


puts "Returns a list of prime numbers from 1 to < n using trial division algorithm."
#n = (prompt "Input limit: ").to_i
n = 1_000_000

start_time = Time.now
list = getPrimeList(n)
end_time = Time.now

elapsed_time = end_time - start_time
puts "found #{list.size} primes"
printf("elapsed time: %5.3f s.\n", elapsed_time.to_f)

#answer = prompt "Print them ? (y/n) "
#puts list.inspect if answer.strip == 'y'

