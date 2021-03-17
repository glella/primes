#! /usr/bin/env ruby
# primesractor.rb
# ruby --jit-wait primesractor.rb

def prompt(*args)
    print(*args)
    gets
end

def is_prime?(n)
	# return true if n == 2
	# return false if n < 2 || n % 2 == 0
	limit = Math.sqrt(n).to_i
	divisors = (3..limit).step(2)
	return false if divisors.any? { |d| n % d == 0 }
	return true
end

# Works well but ractors slower than sequential - Must be doing something wrong
# The more ractors used the slower it gets
def parallel_list(n, blocks)
	odds = (3..n).to_a.select { |i| i.odd? }	# get only odd numbers
	size = odds.count / blocks					# size of chunk of numbers per ractor
	chunks = odds.each_slice(size).to_a			# separate numbers in chunks (array of arrays)
	result = []
	result << 2									# add 2 to result array as we start at 3

	# spawn ractors
	ractors = []								# to hold the ractors
	chunks.each { |segment|
		r = Ractor.new do 						# create the ractor
			list = Ractor.receive				# receive message with segment
			temp = []							# temp to hold list of primes
			list.each { |i|
				temp << i if is_prime?(i)	
			}
			Ractor.yield(temp)					# return message with list of primes
		end
		ractors << r 							# save ractor in array
		r.send(segment, move: true)				# send the message with chunk giving ownership
	} 
	
	# receive the results
	result << ractors.map(&:take)				# accumulate all the results arrays

	# return the array
	return result.flatten!						# flatten the array into a single one
end


def secuential_list(n)
	return [] if n < 2
	result = [2]
	odd = (3...n).step(2).to_a
	odd.each do |i|
		divisors = (3..Math.sqrt(i)).step(2)
		result << i if divisors.none? { |d| i % d == 0 }
	end
	return result
end

puts "Returns a list of prime numbers from 1 to < n using trial division algorithm."
n = (prompt "Input limit: ").to_i

threads = (prompt "Number of Threads to use: ").to_i

start_time = Time.now
#list = secuential_list(n)
list = parallel_list(n, threads)
end_time = Time.now

elapsed_time = end_time - start_time
puts "found #{list.length} primes"
printf("elapsed time: %5.3f s.\n", elapsed_time)

answer = prompt "Print them ? (y/n) "
puts list.inspect if answer.strip == 'y'

