extern crate rayon;

use std::time::Instant;
use std::io;
use std::io::Write; // <--- bring flush() into scope

use rayon::prelude::*;
use std::sync::{Arc, Mutex};

fn is_prime(n: u64) -> bool {
    match n {
        0 | 1 => false,
        2 => true,
        _even if n % 2 == 0 => false,
        _ => {
            let sqrt_limit = (n as f64).sqrt() as u64;
            !(3..=sqrt_limit).step_by(2).any(|i| n % i == 0) 
        }
    }
}
 
fn prompt(s: &str) -> String {
	let mut text = String::new();
	print!("{} ", s); // input on the same line
	io::stdout().flush().unwrap(); // flush it to the screen immediatly like println!
    io::stdin()
        .read_line(&mut text)
        .expect("failed to read from stdin");
    text
}

fn main() {
	
	println!("Looks for prime numbers from 1 to your input");

	let result = Arc::new(Mutex::new(Vec::new())); // To be able to write to it concurrently

	loop {
		result.lock().unwrap().clear(); // clears the result array for subsequent loops
		let mut input = prompt("Seek until what integer number?");
    	let mut n = 0;
    	match input.trim().parse::<u32>() {
        	Ok(i) => n = i,
        	Err(..) => println!("That was not an integer."),
    	};

    	let num = n as u64; // cast it to u64
    	let now = Instant::now(); // start timer

    	let num_vector: Vec<u64> = (1..=num).collect();
    	num_vector.into_par_iter().for_each(|i| {  // parallel iterator - All it takes!
    		if is_prime(i) {
            	result.lock().unwrap().push(i); // to be able to write to it concurrently
        	}
		});
    	
    	let elapsed = now.elapsed(); // check time elapsed
    	let sec = (elapsed.as_secs() as f64) + (elapsed.subsec_nanos() as f64 / 1000_000_000.0);
    	println!("Seconds: {:.3}", sec);
    	println!("Number of primes: {}", result.lock().unwrap().len()); // lock & unwrap it

    	input = prompt("Print primes? (y/n)");
    	if input.trim() == "y" {
    		println!("{:?}", result.lock().unwrap()); // lock & unwrap it
    	}

    	input = prompt("Another run? (y/n)");
    	if input.trim() != "y" {
    		break;
    	}

    	println!("");

    }
    
}