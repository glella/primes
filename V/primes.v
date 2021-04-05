// v -autofree primes.v  
import os
import time

// the match statement did not allow to have a for loop in the else clause
fn is_prime(num int) bool {
	mut n := num
	if n < 0 {
		n = -n
	}
	if n < 2 {
		return false
	} else if n == 2 {
		return true
	} else if n%2 == 0 {
		return false
	} else { 
		for i := 3; i*i <= n; i += 2 {
			if n%i == 0 {
				return false
			}
		}
	}
	return true
}

fn main() {
	println('\nSearch primes using trial division algorithm.')
	for {	
		mut resp := os.input('\nPlease enter search number limit: ').trim_space()
		num := resp.int() 
		mut result := [2]		// add manually 2 as we start checking at 3
		
		start := time.now()		// <<<< start clock
		for i := 3; i <= num; i += 2 {
			if is_prime(i) {
				result << i
			}
		}
		end := time.now()		// <<<< stop clock
		elapsed := f64(end - start) / 1_000_000_000.0	
		println('Took: ${elapsed:.3f} secs.')
		println('Found: ${result.len} primes.')

		resp = os.input('Print primes? (y/n): ').trim_space()
		if compare_strings('y', resp) == 0 {
			println(result)
		}

		resp = os.input('Another run? (y/n): ').trim_space()
		if compare_strings('y', resp) != 0 {
			break
		}

	}
	
}