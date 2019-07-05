
use std::time::Instant;
use std::io;
use std::io::Write; // <--- bring flush() into scope

fn my_is_prime(n: u64) -> bool {
    match n {
        0 | 1 => false,
        2 => true,
        _even if n % 2 == 0 => false,
        _ => {
            let sqrt_limit = (n as f64).sqrt() as u64;
            //(3..=sqrt_limit).step_by(2).find(|i| n % i == 0).is_none()
            for i in (3..=sqrt_limit).step_by(2) {
            	if n % i == 0 {
            		return false;
            	}
            }
            return true;
        }
    }
}
 
fn main() {
	
	println!("Looks for prime numbers from 1 to your input");
	let mut input = String::new();	
	let mut result = Vec::new();

	loop {
		input.clear();
		result.clear();
		print!("Seek until what integer number ? ", ); // input on the same line
		io::stdout().flush().unwrap(); // flush it to the screen 
    	
    	io::stdin()
        	.read_line(&mut input)
        	.expect("failed to read from stdin");
    	let mut n = 0;
    	match input.trim().parse::<u32>() {
        	Ok(i) => n = i,
        	Err(..) => println!("That was not an integer."),
    	};

    	let num = n as u64; // cast it to u64
    	let now = Instant::now(); // start timer

    	for i in 1..num {
        	if my_is_prime(i) {
            	result.push(i);
        	}
    	}

    	let elapsed = now.elapsed(); // check time elapsed
    	let sec = (elapsed.as_secs() as f64) + (elapsed.subsec_nanos() as f64 / 1000_000_000.0);
    	println!("Seconds: {:.3}", sec);
    	println!("Number of primes: {}", result.len());

    	print!("Another run? (y/n) ", );
    	io::stdout().flush().unwrap();
    	input.clear();
    	io::stdin()
        	.read_line(&mut input)
        	.expect("failed to read from stdin");

    	if input.trim() != "y" {
    		break;
    	}

    	println!("");

    }
    
}