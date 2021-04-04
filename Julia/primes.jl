#!/usr/bin/julia
#julia primes.jl

function Input(prompt)::String
    print(prompt)
    return chomp(readline())
end

function check_primes(limit)
	sq = limit^0.5
    for i in 3:2:trunc(Int, sq)
        limit%i != 0 || return false
    end
    return true
end

function prime_list(limit)
	result = Int64[]
	push!(result, 2)
	for x in 3:2:limit
		if check_primes(x)
			push!(result, x)
		end
	end
	result
end

function calc_primes(bound)
    @time p = prime_list(bound)
    print(length(p)," primes found\n")
end
 
while true
	println("*** Looks for primes ***")
	n = Input("Seek primes until what number? ")
	num = parse(Int64, n)
	
	calc_primes(num)
	
	resp = Input("Another run? (y/n) ")
	if resp != "y"
		break
	end
	println("")
end

