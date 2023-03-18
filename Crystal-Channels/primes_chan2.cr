# bash:
# CRYSTAL_WORKERS=16; crystal build --release -Dpreview_mt -o primes primes_chan2.cr
# fish:
# set CRYSTAL_WORKERS 16
# crystal build --release -Dpreview_mt -o primes primes_chan.cr

def prompt(*args)
  print(*args)
  gets(chomp = true)
end

def is_prime?(n)
  # return true if n == 2
  # return false if n < 2 || n % 2 == 0
  limit = Math.sqrt(n).to_i
  divisors = (3..limit).step(2)
  return false if divisors.any? { |d| n % d == 0 }
  return true
end

# def is_prime?(n)
#   # return true if n == 2
#   # return false if n < 2 || n % 2 == 0
#   limit = n - 1
#   i = 3
#   while i <= limit
#     return false if n % i == 0
#     limit = n / i # update the limit variable to be n / i, which is a new upper bound on the possible divisors of n
#     i += 2
#   end
#   return true
# end

def search(ranges)
  result = Array(Int32).new
  result << 2 # manually insert 2 as we start doing math with odd numbers
  ch = Channel(Array(Int32)).new(16)

  ranges.each { |segment| # for each subarray create a new fiber
 spawn do
    temp = [] of Int32
    segment.each { |i|
      temp << i if is_prime?(i)
    }
    ch.send(temp)
  end }

  # receive data from channels
  ranges.each { |segment|
    result += ch.receive
  }

  result
end

# "main"
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

# test only odd numbers starting at 3 until input limit
odd = (3...n).step(2).to_a
# split the array into chunks using number of threads input
chunk_size = (odd.size / threads.to_f).ceil.to_i # round up to nearest integer
chunks = odd.each_slice(chunk_size).to_a

list = [] of Int32
elapsed_time = Time.measure do
  list = search(chunks)
end

puts "found #{list.size} primes"
printf("elapsed time: %d milliseconds.\n", elapsed_time.milliseconds)

answer = (prompt "Print them ? (y/n) ")
if answer
  puts list.inspect if answer.strip == "y"
end
