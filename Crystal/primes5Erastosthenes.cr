#! /usr/bin/env ruby


def prompt(*args)
    print(*args)
    gets(chomp = true)
end

def getPrimeList(n)
	return Array(Int32).new if n < 2
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
	#nums = [nil, nil, *2..n]
	nums = [nil, nil]
	nums += (2..n).to_a

	(2..Math.sqrt(n)).each do |i|
		(i**2..n).step(i) {|m| nums[m] = nil}  #if nums[i]
  	end
  	nums.compact
end

puts "Returns a list of prime numbers from 1 to < n using trial division algorithm."
n = (prompt "Input limit: ").try &.to_i?
if !n
	puts "Not a valid number"
	exit 1
end

list = [] of Int32
elapsed_time = Time.measure do
	list = getPrimeList(n)
	#list = eratosthenes(n)
end

puts "found #{list.size} primes"
printf("elapsed time: %d milliseconds.\n", elapsed_time.milliseconds)

answer = (prompt "Print them ? (y/n) ")
if answer
	puts list.inspect if answer.strip == "y"
end


