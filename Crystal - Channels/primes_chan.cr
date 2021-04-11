#! /usr/bin/env ruby
# bash:
# CRYSTAL_WORKERS=16; crystal build --release -Dpreview_mt -o primes6 primes6channels.cr
# fish:
# set CRYSTAL_WORKERS 16
# crystal build --release -Dpreview_mt -o primes primes_chan.cr

def prompt(*args)
  print(*args)
  gets(chomp = true)
end

def is_prime?(n)
  return true if n == 2
  return false if n < 2 || n % 2 == 0
  limit = Math.sqrt(n).to_i
  divisors = (3..limit).step(2)
  return false if divisors.any? { |d| n % d == 0 }
  return true
end

# create array of only odd numbers - do not include upper limit
def make_range(min, max)
  return (min...max).to_a.select { |i| i.odd? }
end

# divide numbers to search by the number of threads
def prep_search(n, threads)
  range_size = n // threads
  reminder = n % threads

  # initial sizes without reminder
  range_sizes_arr = [] of Int32
  (0...threads).each { |item|
    range_sizes_arr << range_size
  }

  # spread the reminder - doint it with map! was cumbersome
  counter = 0
  while reminder > 0
    range_sizes_arr[counter] += 1
    counter += 1
    reminder -= 1
  end

  # create array of arrays to be returned
  arr_of_arr = Array(Array(Int32)).new
  min = 1
  max = 0
  range_sizes_arr.each { |i|
    max = min + i
    arr_of_arr << make_range(min, max)
    min = max
  }

  return arr_of_arr
end

# do the actual search using fibers
def search(ranges)
  result = Array(Int32).new
  result << 2 # manually insert 2 as we start doing math with odd numbers
  # ch = Channel(Int32).new(16) # different buffer sizes no appreciable difference
  ch = Channel(Array(Int32)).new(16)

  # this is done number by number
  # # start threads
  # ranges.each { |segment|		# for each subarray create a new fiber
  # 	spawn do
  # 		segment.each { |i|
  # 			if is_prime?(i)
  # 				ch.send(i)
  # 			else
  # 				ch.send(-1)	# should not need to do this but had to balance same number
  # 			end				# of send and receives. Do not know if there is something
  # 		}					# like a waitgroup
  # 	end
  # }

  # # receive
  # ranges.each { |segment|
  # 	segment.each { |i|
  # 		#result << ch.receive # this is slower as we have to later eliminate -1 from array
  # 		temp = ch.receive
  # 		result << temp if temp > 0	# just avoid adding the -1 numbers
  # 	}
  # }

  # this is done 1 array at a time - much less messages through the channels
  # start threads
  ranges.each { |segment| # for each subarray create a new fiber
    spawn do
        temp = [] of Int32
        segment.each { |i|
          temp << i if is_prime?(i)
        }
        ch.send(temp)
    end 
  }

  # receive
  ranges.each { |segment|
    # temp = ch.receive
    # result += temp
    result += ch.receive
  }

  result
end

# not used in this threads version
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

# not used in this threads version
def eratosthenes(n)
  # nums = [nil, nil, *2..n]
  nums = [nil, nil]
  nums += (2..n).to_a

  (2..Math.sqrt(n)).each do |i|
    (i**2..n).step(i) { |m| nums[m] = nil } # if nums[i]
  end
  nums.compact
end

# here is "main"
puts "Returns a list of prime numbers from 1 to < n using trial division algorithm."
n = (prompt "Input limit: ").try &.to_i?
if !n
  puts "Not a valid number"
  exit 1
end

threads = (prompt "Number of Threads to use: ").try &.to_i?
if !threads
  puts "Not a valid number"
  exit 1
end

search_vectors = prep_search(n, threads)

list = [] of Int32
elapsed_time = Time.measure do
  # list = getPrimeList(n)
  # list = eratosthenes(n)
  list = search(search_vectors)
end

puts "found #{list.size} primes"
printf("elapsed time: %d milliseconds.\n", elapsed_time.milliseconds)

answer = (prompt "Print them ? (y/n) ")
if answer
  puts list.inspect if answer.strip == "y"
end

# tests
# puts "testing is_prime?"
# puts "2 is true" if is_prime?(2)
# puts "4 is false" if !is_prime?(4)
# puts "3 is true" if is_prime?(3)
# puts "7 is true" if is_prime?(7)
# puts "15 is false" if !is_prime?(15)
# puts "12 is false" if !is_prime?(12)
# puts "97 is true" if is_prime?(97)
# puts "9 is false" if !is_prime?(9)

# puts "testing make_range"
# test_range = [11, 13, 15, 17, 19, 21, 23]
# range = make_range(11, 25)
# puts "it works" if range == test_range
# puts range
# puts test_range

# puts "testing prep_search"
# result = Array(Array(Int32)).new
# result << make_range(1, 35)
# result << make_range(35, 68)
# result << make_range(68, 101)
# puts result
# test_arr = prep_search(100, 3)
# puts test_arr
# puts "it works" if test_arr == result
