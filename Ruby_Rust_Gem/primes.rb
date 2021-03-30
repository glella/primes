#! /usr/bin/env ruby
# ruby primes.rb
require 'Primesrs'


def prompt(*args)
    print(*args)
    gets
end

puts "Returns a list of prime numbers from 1 to < n using Rust & Rayon."
n = (prompt "Input limit: ").to_i

start_time = Time.now
list = Primesrs[n]
end_time = Time.now

elapsed_time = end_time - start_time
puts "found #{list.length} primes"
printf("elapsed time: %5.3f s.\n", elapsed_time)

answer = prompt "Print them ? (y/n) "
puts list.inspect if answer.strip == 'y'

